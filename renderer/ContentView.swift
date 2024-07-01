//
//  ContentView.swift
//  renderer
//
//  Created by James Penrose on 5/22/24.
//

import SwiftUI
import GameController

//asdfagre
struct ContentView: View {
    
    
    private let angleChangeRadians = Double.pi/20
    private let movementAmount = 0.1
    
    @State private var camera = Camera(
        frameCenter: Point3d(x: 0, y: 0, z: 1),
        direction: Vector3d(Point3d(x: 0, y: 0, z: -1)).normalize(),
        fovRadians: 70/180 * Double.pi,
        frameWidth: 1,
        frameHeight: 1
    )
    
    @State private var displayMode = DrawToScreen.DisplayMode.Wireframe
    
    private func changeHorizontal(angleChangeRadians: Double) {
        camera = camera.changeAngle(horizontalAngleChangeRadians: -angleChangeRadians, verticalAngleChangeRadians: 0)
    }
    
    private func changeVertical(angleChangeRadians: Double) {
        camera = camera.changeAngle(horizontalAngleChangeRadians: 0, verticalAngleChangeRadians: angleChangeRadians)
    }
    
    private func translateBy(_ positionChange: Point3d) {
        let positionChangeVector = Vector3d(Point3d(x: positionChange.x, y: positionChange.y, z: -positionChange.z))
        
        let vert = Vector3d(Point3d(x: 0, y: 1, z: 0))
        
        let forward = vert.cross(camera.horizontalDirection)
        
        let adjustedPositionChange = positionChangeVector.translated(matrixColumns: [
            camera.horizontalDirection.dimensions,
            vert.dimensions,
            forward.dimensions
        ])
        
        camera = camera.changeFrameCenter(frameCenterChange: adjustedPositionChange.toPoint3d())
    }
    
    var body: some View {
        
        
        let platforms = [
            Cuboid(color: .brown, center: Point3d(x: 0, y: -1, z: 0), xLength: 2, yLength: 0.5, zLength: 2)
        ]
        let platformMeshes = platforms.flatMap { platform in platform.mesh() }
        
        let cube2 = Cuboid(color: .green, center: Point3d(x: 5, y: 0, z: 2), xLength: 1, yLength: 1, zLength: 1).mesh()
        
        
        let xOrigin = Surface3d(triangles: [Triangle(orderedVertices: [
            Point3d(x: 0, y: 0, z: 0),
            Point3d(x: 0, y: 1, z: 0),
            Point3d(x: 0, y: 0, z: 1),
        ])], color: .red)
        let yOrigin = Surface3d(triangles: [Triangle(orderedVertices: [
            Point3d(x: 0, y: 0, z: 0),
            Point3d(x: 1, y: 0, z: 0),
            Point3d(x: 0, y: 0, z: 1),
        ])], color: .green)
        let zOrigin = Surface3d(triangles: [Triangle(orderedVertices: [
            Point3d(x: 0, y: 0, z: 0),
            Point3d(x: 1, y: 0, z: 0),
            Point3d(x: 0, y: 1, z: 0),
        ])], color: .blue)
        
        let renderer = Renderer3d()
        let drawToScreen = DrawToScreen()
        
        let gamepad = GamepadView()
        
        
        let canvas = Canvas { context, size in
            
            let rendering: [Surface2d] = renderer.render(camera: camera, objects: 
                platformMeshes + cube2 + [
                    xOrigin,
                    yOrigin,
                    zOrigin
                ]
            )
            
            drawToScreen.draw(
                rendering: rendering,
                camera: camera,
                frameSize: size,
                context: context,
                displayMode: displayMode
            )
            
        }
        .focusable()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ it in
                    print("it.velocity.width: \(it.velocity.width)")
                    print("it.velocity.height: \(it.velocity.height)")
                    
                    let xRotation = veloToRadian(velocity: it.translation.width)
                    print("xRotation: \(xRotation)")
                    
                    func veloToRadian(velocity: Double) -> Double {
                        return (min(velocity, 20)/20) * (Double.pi/200)
                    }
                    
                    changeHorizontal(angleChangeRadians: xRotation)
                    
                })
        )
        .onKeyPress(action:  { press in
            
            switch (press.key) {
            case KeyEquivalent.upArrow:
                changeVertical(angleChangeRadians: angleChangeRadians)
                break
            case KeyEquivalent.downArrow:
                changeVertical(angleChangeRadians: -angleChangeRadians)
                break
            case KeyEquivalent.rightArrow:
                changeHorizontal(angleChangeRadians: -angleChangeRadians)
                break
            case KeyEquivalent.leftArrow:
                changeHorizontal(angleChangeRadians: angleChangeRadians)
                break
            case KeyEquivalent.space:
                translateBy(Point3d(x: 0, y: movementAmount, z: 0))
                break
            default:
                switch (press.characters) {
                case "w":
                    translateBy(Point3d(x: 0, y: 0, z: movementAmount))
                    break
                case "s":
                    translateBy(Point3d(x: 0, y: 0, z: -movementAmount))
                    break
                case "a":
                    translateBy(Point3d(x: -movementAmount, y: 0, z: 0))
                    break
                case "d":
                    translateBy(Point3d(x: movementAmount, y: 0, z: 0))
                    break
                case "c":
                    translateBy(Point3d(x: 0, y: -movementAmount, z: 0))
                    break
                default:
                    switch(press.modifiers) {
                    case EventModifiers.control:
                        translateBy(Point3d(x: 0, y: -movementAmount, z: 0))
                        break
                    default:
                        break
                    }
                    break
                }
                break
            }
            return .handled
        })
        return ZStack {
            canvas
            gamepad.onAppear(perform: {
                print("hi there")
                
                gamepad.vc.virtualController!.controller!.gamepad!.valueChangedHandler = { (value, fdas) in
                    let controller = value.controller?.extendedGamepad!
                    
                    let leftStick = controller?.leftThumbstick
                    let leftY = Double(leftStick?.yAxis.value ?? 0)
                    let leftX = Double(leftStick?.xAxis.value ?? 0)
                    
                    let upDown: Double;
                    if (controller?.buttonX.isPressed == true) {
                        upDown = movementAmount
                    } else if (controller?.buttonA.isPressed == true) {
                        upDown = -movementAmount
                    } else {
                        upDown = 0
                    }
                    
                    let movementSpeedMultiplier = 0.3
                    translateBy(Point3d(
                        x: leftX * movementSpeedMultiplier,
                        y: upDown,
                        z: leftY * movementSpeedMultiplier
                    ))
                    
                    let rightStick = controller?.rightThumbstick
                    let rightX = Double(rightStick?.xAxis.value ?? 0)
                    let rightY = Double(rightStick?.yAxis.value ?? 0)
                    
                    let rotationSpeedMultiplier = 0.08
                    camera = camera.changeAngle(
                        horizontalAngleChangeRadians: rotationSpeedMultiplier * -rightX,
                        verticalAngleChangeRadians: 0//rotationSpeedMultiplier * rightY
                    )
                    
                    if (controller!.buttonB.isPressed == true) {
                        displayMode = switch (displayMode) {
                        case .Wireframe:
                                .Surface
                        case .Surface:
                                .Wireframe
                        }
                    }
                }
            })
        }
    }
}

#Preview {
    ContentView()
}
