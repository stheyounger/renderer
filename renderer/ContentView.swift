//
//  ContentView.swift
//  renderer
//
//  Created by James Penrose on 5/22/24.
//

import SwiftUI

struct Point2d {
    let x: Double
    let y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
}

struct Point3d {
    let x: Double
    let y: Double
    let z: Double
    
    init(x: Double, y: Double, z: Double) {
        self.x = x
        self.y = y
        self.z = z
    }
    
    func rotateAroundZ(rotationCenter: Point3d, angleRadians: Double) -> Point3d {
        let distanceFromRotationCenter = hypot(self.x - rotationCenter.x, self.y - rotationCenter.y)
        let angleToRotationCenterRad = atan2(self.y - rotationCenter.y, self.x - rotationCenter.x) + angleRadians
            
        let rotated =  Point3d(x: rotationCenter.x + (cos(angleToRotationCenterRad) * distanceFromRotationCenter),
                           y: rotationCenter.y + (sin(angleToRotationCenterRad) * distanceFromRotationCenter),
                           z: self.z)
        return rotated
    }
    
    func rotateAroundY(rotationCenter: Point3d, angleRadians: Double) -> Point3d {
        let distanceFromRotationCenter = hypot(self.x - rotationCenter.x, self.z - rotationCenter.z)
        let angleToRotationCenterRad = atan2(self.z - rotationCenter.z, self.x - rotationCenter.x) + angleRadians
        
        let rotated = Point3d(x: rotationCenter.x + (cos(angleToRotationCenterRad) * distanceFromRotationCenter),
                       y: self.y,
                       z: rotationCenter.z + (sin(angleToRotationCenterRad) * distanceFromRotationCenter))
        return rotated
    }
    
    func rotateAroundX(rotationCenter: Point3d, angleRadians: Double) -> Point3d {
        let distanceFromRotationCenter = hypot(self.y - rotationCenter.y, self.z - rotationCenter.z)
        let angleToRotationCenterRad = atan2(self.z - rotationCenter.z, self.y - rotationCenter.y) + angleRadians
        
        let rotated = Point3d(x: self.x,
                       y: rotationCenter.y + (sin(angleToRotationCenterRad) * distanceFromRotationCenter),
                       z: rotationCenter.z + (cos(angleToRotationCenterRad) * distanceFromRotationCenter))
        return rotated
    }
}

struct Line<Point> {
    let start: Point
    let end: Point
    
    init (start: Point, end: Point) {
        self.start = start
        self.end = end
    }
}

struct Cube {
    let polygonMesh: PolygonMesh

    init (origin: Point3d, sideLength: Double) {
        let halfLength = sideLength/2
    
//        let triangles = [
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength)),
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength)),
//            
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength)),
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength)),
//            
//            Triangle(Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength)),
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength)),
//            
//            Triangle(Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength)),
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength)),
//            
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength)),
//            Triangle(Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
//                     Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength)),
//        ]
        
        
//        let dfsa: (String, Int) = ("hi", 2)
        
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
        
        self.polygonMesh = PolygonMesh(triangles: triangles)
    }
}


struct Triangle {
    let orderedVertices: [Point3d]
    
    init(_ vertex1: Point3d, _ vertex2: Point3d, _ vertex3: Point3d) {
        self.orderedVertices = [vertex1, vertex2, vertex3]
    }
    
    init(orderedVertices: [Point3d]) {
        self.orderedVertices = orderedVertices
    }
}

struct PolygonMesh {
    let triangles: [Triangle]
    
    init(triangles: [Triangle]) {
        self.triangles = triangles
    }
    
    
    func rotateAroundY(rotationCenter: Point3d, angleRadians: Double) -> PolygonMesh {
        return PolygonMesh(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundY(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
    func rotateAroundX(rotationCenter: Point3d, angleRadians: Double) -> PolygonMesh {
        return PolygonMesh(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundX(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
}

struct Renderer3d {
    func render(shape3d: PolygonMesh) -> [Line<Point2d>] {
        
        let wireframe = shape3d.triangles.flatMap { triangle in
            triangle.orderedVertices.flatMap { vertex in
                triangle.orderedVertices.map { otherVertex in
                    Line(start: vertex, end: otherVertex)
                }
            }
        }
        
        let flattened = wireframe.map { line in
            let start2d = Point2d(x: line.start.x, y: line.start.y)
            let end2d = Point2d(x: line.end.x, y: line.end.y)
            return Line(start: start2d, end: end2d)
        }
        
        
        return flattened
    }
}


struct ContentView: View {
    
    @State private var yAngleRadians = 0.0
    @State private var xAngleRadians = 0.0
    private let angleChangeRadians = Double.pi/20
    
    var body: some View {
    
        let cubeOrigin = Point3d(x: 100, y: 100, z: 100)
        let cube = Cube(origin: cubeOrigin, sideLength: 60)
        
        
        let renderer = Renderer3d()
        
        Canvas { context, size in
            
            
            let rotatedCube = cube.polygonMesh.rotateAroundY(rotationCenter: cubeOrigin, angleRadians: yAngleRadians).rotateAroundX(rotationCenter: cubeOrigin, angleRadians: xAngleRadians)
            
            let projection = renderer.render(shape3d: rotatedCube)
            
            let path = CGMutablePath()
            for (i, line) in projection.enumerated() {
                
                let start = CGPoint(x: line.start.x, y: line.start.y)
                path.move(to: start)
                
                let end = CGPoint(x: line.end.x, y: line.end.y)
                path.addLine(to: end)
            }
            
            context.stroke(Path(path),
                           with: .color(.green),
                           lineWidth: 3)
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
                    yAngleRadians += yRotation
                    
                })
        )
        .onKeyPress { press in
            switch (press.key) {
                case KeyEquivalent.leftArrow:
                    yAngleRadians += angleChangeRadians
                    break
                case KeyEquivalent.rightArrow:
                    yAngleRadians -= angleChangeRadians
                    break
                case KeyEquivalent.upArrow:
                    xAngleRadians += angleChangeRadians
                    break
                case KeyEquivalent.downArrow:
                    xAngleRadians -= angleChangeRadians
                    break
                default:
                    break
            }
            return .handled
        }
    }
}

#Preview {
    ContentView()
}
