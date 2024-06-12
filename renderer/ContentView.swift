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
    let triangles: [Triangle<Point3d>]
    let color: Color
    
    init(triangles: [Triangle<Point3d>], color: Color) {
        self.triangles = triangles
        self.color = color
    }
    
    func copyColor(triangles: [Triangle<Point3d>]) -> Surface3d {
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
    let triangles: [Triangle<Point2d>]
    let color: Color
    
    init(triangles: [Triangle<Point2d>], color: Color) {
        self.triangles = triangles
        self.color = color
    }
}


struct ContentView: View {
    
    private let angleChangeRadians = Double.pi/20
    private let movementAmount = 0.1
    
    
    @State private var frameCenter = Point3d(x: 0, y: 0, z: 1)
//    @State private var direction = Vector3d(Point3d(x: sin(xAngleRadians), y: 0, z: cos(xAngleRadians)))
    @State private var direction = Vector3d(Point3d(x: 0, y: 0, z: -1)).normalize()
    
    
    func reorientCoordinates(_ point: Point2d, frameSize: CGSize, camera: Camera) -> Point2d {
        func centerPoint(_ point: Point2d) -> Point2d {
            let centerX = frameSize.width/2
            let centerY = frameSize.height/2
            
            let flippedY = -point.y
            
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
    private func triangleToCGPath(_ triangle: Triangle<Point2d>) -> Path {
        let cgPoints: [CGPoint] = triangle.orderedVertices.map { point in
            CGPoint(x: point.x, y: point.y)
        }
        
        let path = CGMutablePath()
        cgPoints.enumerated().forEach { i, point in
            if (i == 0) {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        
        return Path(path)
    }
//    kjhkjhg
    private func changeAngle(angleChangeRadians: Double) {
        let directionRadians = atan2(direction.toPoint3d().x, direction.toPoint3d().z)
        
        let newDirectionRadians = directionRadians + angleChangeRadians
        
        direction = Vector3d(Point3d(x: sin(newDirectionRadians), y: 0, z: cos(newDirectionRadians))).normalize()
    }
    
    private func translateBy(_ positionChange: Point3d) {
        let positionChangeVector = Vector3d(positionChange)
        
        let camera = Camera(
            frameCenter: frameCenter,
            direction: direction,
            focalLength: 0.8,
            frameWidth: 1,
            frameHeight: 1
        )
        
        let adjustedPositionChange = positionChangeVector.translated(matrixColumns: [camera.horizontalDirection.dimensions, camera.verticalDirection.dimensions, direction.dimensions])
        
        frameCenter = frameCenter.plus(adjustedPositionChange.toPoint3d())
    }
    
    var body: some View {
        
        let cubeOrigin = Point3d(x: 0, y: 0, z: 1.5)
        let cube = Cube(origin: cubeOrigin, sideLength: 1, color: .green).surface3d
        let cube2 = Cube(origin: Point3d(x: 5, y: 0, z: 2), sideLength: 1, color: .green).surface3d
        
        
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
        
        return Canvas { context, size in
            let camera = Camera(
                frameCenter: frameCenter,
                direction: direction,
                focalLength: 0.8,
                frameWidth: 1,
                frameHeight: 1
            )
            
            
            let rendering: [Surface2d] = renderer.render(camera: camera, objects: [
                cube,
                cube2,
                xOrigin,
                yOrigin,
                zOrigin
            ])
            
            
            let reorientedCoordinates: [Surface2d] = rendering.map { surface in
                let triangles = surface.triangles
                let color = surface.color
                
                let adjustedTriangles = triangles.map { triangle in
                    Triangle(orderedVertices: triangle.orderedVertices.map { point in
                        reorientCoordinates(point, frameSize: size, camera: camera)
                    })
                }
                
                return Surface2d(triangles: adjustedTriangles, color: color)
            }
            
            reorientedCoordinates.forEach { surface in
                surface.triangles.forEach { triangle in
                    context.fill(triangleToCGPath(triangle), with: .color(surface.color))
                }
            }

            
            let debug = [
                Point2d(x: 0.1, y: 0.1),
                Point2d(x: -0.1, y: -0.1),
                Point2d(x: 0.1, y: -0.1),
                Point2d(x: -0.1, y: 0.1),
                Point2d(x: 0.3, y: 0),
                ]
            debug.forEach { point in
                let reorientedPoint = reorientCoordinates(point, frameSize: size, camera: camera)
                let origin = reorientCoordinates(Point2d(x: 0, y: 0), frameSize: size, camera: camera)
                
//                context.stroke(lineToCGPath(Line(start: origin, end: reorientedPoint)), with: .color(.white), lineWidth: 5)
            }
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
                    
                    
                    changeAngle(angleChangeRadians: xRotation)
                    
                })
        )
        .onKeyPress(action:  { press in
            
            switch (press.key) {
            case KeyEquivalent.rightArrow:
                changeAngle(angleChangeRadians: -angleChangeRadians)
                break
            case KeyEquivalent.leftArrow:
                changeAngle(angleChangeRadians: angleChangeRadians)
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
    }
}

#Preview {
    ContentView()
}
