//
//  ContentView.swift
//  renderer
//
//  Created by James Penrose on 5/22/24.
//

import SwiftUI

struct Cube {
    
    let origin: Point3d
    let sideLength: Double
    let color: Color
    let orderedVertices: [Point3d]

    init (origin: Point3d, sideLength: Double, color: Color) {
        self.origin = origin
        self.sideLength = sideLength
        self.color = color
        
        let halfLength = sideLength/2
        
        self.orderedVertices = [
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
        ]
    }
    
    func mesh() -> [Surface3d] {
        let vertices = orderedVertices
        return [
            Surface3d(triangles: [
                //Top
                Triangle(vertices[0], vertices[1], vertices[3]),
                Triangle(vertices[2], vertices[1], vertices[3]),
            ], color: color),
            Surface3d(triangles: [
                //Bottom
                Triangle(vertices[4], vertices[5], vertices[7]),
                Triangle(vertices[6], vertices[5], vertices[7]),
            ], color: color),
            Surface3d(triangles: [
                //Side
                Triangle(vertices[0], vertices[4], vertices[5]),
                Triangle(vertices[0], vertices[1], vertices[5]),
            ], color: color),
            Surface3d(triangles: [
                //Other Side
                Triangle(vertices[2], vertices[3], vertices[7]),
                Triangle(vertices[2], vertices[6], vertices[7]),
            ], color: color),
        ]
    }
    
//    func isColliding(_ other: Object) -> Bool {
//        return false
//    }
}

struct Cuboid {
    
    let center: Point3d
    let xLength: Double
    let yLength: Double
    let zLength: Double
    let color: Color
    let orderedVertices: [Point3d]

    init (color: Color, center: Point3d, xLength: Double, yLength: Double, zLength: Double) {
        self.color = color
        self.center = center
        self.xLength = xLength
        self.yLength = yLength
        self.zLength = zLength
        
        let halfXLength = xLength/2
        let halfYLength = yLength/2
        let halfZLength = zLength/2
        
        self.orderedVertices = [
            Point3d(x: center.x+halfXLength, y: center.y+halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x+halfXLength, y: center.y-halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y-halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y+halfYLength, z: center.z+halfZLength),
            
            Point3d(x: center.x+halfXLength, y: center.y+halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x+halfXLength, y: center.y-halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y-halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y+halfYLength, z: center.z-halfZLength),
        ]
    }
    
    func mesh() -> [Surface3d] {
        let vertices = orderedVertices
        return [
            Surface3d(triangles: [
                //Front
                Triangle(vertices[0], vertices[1], vertices[3]),
                Triangle(vertices[2], vertices[1], vertices[3]),
            ], color: color),
            Surface3d(triangles: [
                //Back
                Triangle(vertices[4], vertices[5], vertices[7]),
                Triangle(vertices[6], vertices[5], vertices[7]),
            ], color: color),
            Surface3d(triangles: [
                //Side
                Triangle(vertices[0], vertices[4], vertices[5]),
                Triangle(vertices[0], vertices[1], vertices[5]),
            ], color: color),
            Surface3d(triangles: [
                //Other Side
                Triangle(vertices[2], vertices[3], vertices[7]),
                Triangle(vertices[2], vertices[6], vertices[7]),
            ], color: color),
            Surface3d(triangles: [
                //Top
                Triangle(vertices[0], vertices[3], vertices[4]),
                Triangle(vertices[7], vertices[3], vertices[4]),
            ], color: color),
            Surface3d(triangles: [
                //Bottom
                Triangle(vertices[1], vertices[5], vertices[2]),
                Triangle(vertices[6], vertices[5], vertices[2]),
            ], color: color),
        ]
    }
}

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
            
            func handleInfinity(_ n: Double) -> Double {
                return if (n == Double.infinity || n == Double.nan || n == Double.signalingNaN) {
                    Double.greatestFiniteMagnitude
                } else {
                    n
                }
            }
            
            let stretched = Point2d(
                x: handleInfinity(point.x * cameraToWindowConversion),
                y: handleInfinity(point.y * cameraToWindowConversion)
            )
            
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
    
    private func polygonToCGPath(_ polygon: Polygon<Point2d>) -> Path {
        let cgPoints: [CGPoint] = polygon.orderedVertices.map { point in
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
        
//        let cube = Cube(origin: Point3d(x: 0, y: 0, z: 1.5), sideLength: 4, color: .green).mesh()
        let cube2 = Cube(origin: Point3d(x: 5, y: 0, z: 2), sideLength: 1, color: .green).mesh()
        
        
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
            
            let rendering: [Surface2d] = renderer.render(camera: camera, objects: 
                platformMeshes + cube2 + [
//                                                         [
                    xOrigin,
                    yOrigin,
                    zOrigin
                ]
            )
            
            let reorientedCoordinates: [Surface2d] = rendering.map { surface in
                let color = surface.color
                
                let adjustedPolygons = surface.polygons.map { polygon in
                    Polygon<Point2d>(orderedVertices: polygon.orderedVertices.map { point in
                        reorientCoordinates(point, frameSize: size, camera: camera)
                    }).reorderVertices()
                }
                
                return Surface2d(polygons: adjustedPolygons, color: color)
            }
            
            reorientedCoordinates.forEach { surface in
                surface.polygons.forEach { polygon in
                    context.fill(polygonToCGPath(polygon), with: .color(surface.color))
                }
            }
            
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
    }
}

#Preview {
    ContentView()
}
