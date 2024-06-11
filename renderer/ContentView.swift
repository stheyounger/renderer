//
//  ContentView.swift
//  renderer
//
//  Created by James Penrose on 5/22/24.
//

import SwiftUI

struct Cube {
    let surface3d: Surface3d
    let color: Color

    init (origin: Point3d, sideLength: Double, color: Color) {
        self.color = color
        
        let halfLength = sideLength/2
        
        let vertices = [
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
        ]
        
        let triangles = [
            //Top
            Triangle(vertices[0], vertices[1], vertices[3]),
            Triangle(vertices[2], vertices[1], vertices[3]),
            
            //Bottom
            Triangle(vertices[4], vertices[5], vertices[7]),
            Triangle(vertices[6], vertices[5], vertices[7]),
            
            //Side
            Triangle(vertices[0], vertices[4], vertices[5]),
            Triangle(vertices[0], vertices[1], vertices[5]),
            
            //Other Side
            Triangle(vertices[2], vertices[3], vertices[7]),
            Triangle(vertices[2], vertices[6], vertices[7]),
        ]
        
        self.surface3d = Surface3d(triangles: triangles, color: color)
    }
}

struct Surface3d {
    let triangles: [Triangle]
    let color: Color
    
    init(triangles: [Triangle], color: Color) {
        self.triangles = triangles
        self.color = color
    }
    
    func copyColor(triangles: [Triangle]) -> Surface3d {
        return Surface3d(triangles: triangles, color: color)
    }
    
    func rotateAroundY(rotationCenter: Point3d, angleRadians: Double) -> Surface3d {
        return copyColor(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundY(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
    func rotateAroundX(rotationCenter: Point3d, angleRadians: Double) -> Surface3d {
        return copyColor(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundX(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
}

struct Surface2d {
    let lines: [Line<Point2d>]
    let color: Color
    
    init(lines: [Line<Point2d>], color: Color) {
        self.lines = lines
        self.color = color
    }
}


struct ContentView: View {
    
    @State private var xAngleRadians = Double.pi/2
    private let angleChangeRadians = Double.pi/20
    
    @State private var xPosition = 0.0
    @State private var yPosition = 0.0
    @State private var zPosition = 0.0
    private let movementAmount = 0.1
    
    
    func reorientCoordinates(_ point: Point2d, frameSize: CGSize, camera: Camera) -> Point2d {
        func centerPoint(_ point: Point2d) -> Point2d {
            let centerX = frameSize.width/2
            let centerY = frameSize.height/2
            
            let flippedY = point.y * -1
            
            return Point2d(
                x: point.x + centerX,
                y: flippedY + centerY
            )
        }
        
        let smallSideOfWindow = min(frameSize.width, frameSize.height)
        let smallSideOfCamera = min(camera.frameWidth, camera.frameHeight)
        
        let cameraToWindowConversion = smallSideOfWindow/smallSideOfCamera
        
        print("cameraToWindowConversion: \(cameraToWindowConversion)")
        func stretched(_ point: Point2d) -> Point2d {
            let stretched = Point2d(x: point.x * cameraToWindowConversion, y: point.y * cameraToWindowConversion)
            
            print("preStretch: \(point) postStretch: \(stretched)")
            
            return stretched
        }
        
        return centerPoint(stretched(point))
    }
    
    private func lineToCGPath(_ line: Line<Point2d>) -> Path {
        let start = CGPoint(x: line.start.x, y: line.start.y)
        let end = CGPoint(x: line.end.x, y: line.end.y)
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        return Path(path)
    }
    
    var body: some View {
        
        let cubeOrigin = Point3d(x: 0, y: 0, z: 1.5)
        let cube = Cube(origin: cubeOrigin, sideLength: 1, color: .green).surface3d
        let cube2 = Cube(origin: Point3d(x: 5, y: 0, z: 2), sideLength: 1, color: .green).surface3d
        let origin = Surface3d(triangles: [
            Triangle(orderedVertices: [
                Point3d(x: 0, y: 0, z: 0),
                Point3d(x: 1, y: 0, z: 0),
                Point3d(x: 0, y: 0, z: 1),
            ]),
            Triangle(orderedVertices: [
                Point3d(x: 0, y: 0, z: 0),
                Point3d(x: 0, y: 1, z: 0),
                Point3d(x: 0, y: 0, z: 1),
            ]),
            Triangle(orderedVertices: [
                Point3d(x: 0, y: 0, z: 0),
                Point3d(x: 1, y: 0, z: 0),
                Point3d(x: 0, y: 1, z: 0),
            ]),
        ], color: .blue)
        
        let renderer = Renderer3d()
        
        return Canvas { context, size in
            
            let direction = Vector3d(Point3d(x: sin(xAngleRadians), y: 0, z: -cos(xAngleRadians)))
            
            let camera = Camera(
                frameCenter: Point3d(x: xPosition, y: yPosition, z: zPosition),
                direction: direction,
                focalLength: 0.8,
                frameWidth: 1,
                frameHeight: 1
            )
            print("camera center: \(camera.frameCenter)")
            print("camera focal point: \(camera.focalPoint)")
            
            
            let rendering: [Surface2d] = renderer.render(camera: camera, objects: [
                cube,
                cube2,
                origin  
            ])
            
            
            let reorientedCoordinates: [Surface2d] = rendering.map { surface in
                let lines = surface.lines
                let color = surface.color
                
                let adjustedLines: [Line<Point2d>] = lines.map { line in
                    
                    return Line(
                        start: reorientCoordinates(line.start, frameSize: size, camera: camera),
                        end: reorientCoordinates(line.end, frameSize: size, camera: camera)
                    )
                }
                
                return Surface2d(lines: adjustedLines, color: color)
            }
            
            reorientedCoordinates.forEach { surface in
                surface.lines.forEach { line in
                    context.stroke(lineToCGPath(line),
                                   with: .color(surface.color),
                                   lineWidth: 3)
                }
            }
            
            
            
//            let paths: [Renderer3d.ColoredThing<Path>] = centered.map { coloredThing in
//                let lines = coloredThing.thing
//                let color = coloredThing.color
//                
//                let path = lines.map { lines in
//                    
//                    let start = CGPoint(x: line.start.x, y: line.start.y)
//                    let end = CGPoint(x: line.end.x, y: line.end.y)
//                    
//                    let path = CGMutablePath()
//                    path.move(to: start)
//                    path.addLine(to: end)
//                    
//                    return Path(path)
//                }
//                
//                return Renderer3d.ColoredThing(thing: path, color: color)
//            }
//            
//            paths.forEach { coloredThing in
//                let path = coloredThing.thing
//                let color = coloredThing.color
//                
//                context.stroke(path,
//                               with: .color(color),
//                               lineWidth: 3)
//            }
        }
        .focusable()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ it in
                    print("it.velocity.width: \(it.velocity.width)")
                    print("it.velocity.height: \(it.velocity.height)")
                    
                    let xRotation = veloToRadian(velocity: it.velocity.height)
                    let yRotation = veloToRadian(velocity: it.velocity.width)
                    print("xRotation: \(xRotation)")
                    print("yRotation: \(yRotation)")
                    
                    func veloToRadian(velocity: Double) -> Double {
                        return (min(velocity, 20)/20) * (Double.pi/200)
                    }
                    
                    xAngleRadians += xRotation
                    //                    yAngleRadians += yRotation
                    
                })
        )
        .onKeyPress(action:  { press in
            switch (press.key) {
            case KeyEquivalent.rightArrow:
                xAngleRadians += angleChangeRadians
                break
            case KeyEquivalent.leftArrow:
                xAngleRadians -= angleChangeRadians
                break
            case KeyEquivalent.space:
                yPosition += movementAmount
                break
            default:
                switch (press.characters) {
                case "w":
                    zPosition += movementAmount
                    break
                case "s":
                    zPosition -= movementAmount
                    break
                case "a":
                    xPosition -= movementAmount
                    break
                case "d":
                    xPosition += movementAmount
                    break
                case "c":
                    yPosition -= movementAmount
                    break
                default:
                    switch(press.modifiers) {
                    case EventModifiers.control:
                        yPosition -= movementAmount
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
    }
}

#Preview {
    ContentView()
}
