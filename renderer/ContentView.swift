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
}


struct ClosedShape<Point> {
    let orderedVertices: [Point]
    
    init (orderedVertices: [Point]) {
        self.orderedVertices = orderedVertices
    }
}

struct Cube {
    let vertices: [Point3d]
    
    init (vertices: [Point3d]) {
        self.vertices = vertices
    }
    init (origin: Point3d, sideLength: Double) {
        let halfLength = sideLength/2
        self.vertices = [
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z+halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y+halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x-halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
            Point3d(x: origin.x+halfLength, y: origin.y-halfLength, z: origin.z-halfLength),
        ]
    }
    
    func rotateAroundZ(rotationCenter: Point3d, angleRadians: Double) -> Cube {
        let rotated = Cube(vertices: vertices.map { point in
            let distanceFromRotationCenter = hypot(point.x - rotationCenter.x, point.y - rotationCenter.y)
            let angleToRotationCenterRad = atan2(point.y - rotationCenter.y, point.x - rotationCenter.x) + angleRadians
            
            return Point3d(x: rotationCenter.x + (cos(angleToRotationCenterRad) * distanceFromRotationCenter),
                           y: rotationCenter.y + (sin(angleToRotationCenterRad) * distanceFromRotationCenter),
                           z: point.z)
        })
        return rotated
    }
    
    func rotateAroundY(rotationCenter: Point3d, angleRadians: Double) -> Cube {
        let rotated = Cube(vertices: vertices.map { point in
            let distanceFromRotationCenter = hypot(point.x - rotationCenter.x, point.z - rotationCenter.z)
            let angleToRotationCenterRad = atan2(point.z - rotationCenter.z, point.x - rotationCenter.x) + angleRadians
            
            return Point3d(x: rotationCenter.x + (cos(angleToRotationCenterRad) * distanceFromRotationCenter),
                           y: point.y,
                           z: rotationCenter.z + (sin(angleToRotationCenterRad) * distanceFromRotationCenter))
        })
        return rotated
    }
    
    func rotateAroundX(rotationCenter: Point3d, angleRadians: Double) -> Cube {
        let rotated = Cube(vertices: vertices.map { point in
            let distanceFromRotationCenter = hypot(point.y - rotationCenter.y, point.z - rotationCenter.z)
            let angleToRotationCenterRad = atan2(point.z - rotationCenter.z, point.y - rotationCenter.y) + angleRadians
            
            return Point3d(x: point.x,
                           y: rotationCenter.y + (sin(angleToRotationCenterRad) * distanceFromRotationCenter),
                           z: rotationCenter.z + (cos(angleToRotationCenterRad) * distanceFromRotationCenter))
        })
        return rotated
    }
}

struct Renderer3d {
    
    func render(shape3d: ClosedShape<Point3d>) -> ClosedShape<Point2d> {
        
        let wireframe = shape3d.orderedVertices
        
//        let wireframe = shape3d.orderedVertices.flatMap { vertex in
//            shape3d.orderedVertices.flatMap { otherVertex in
//                [vertex, otherVertex]
//            }
//        }
        
        
        let flattened = wireframe.map { vertex in
            Point2d(x: vertex.x, y: vertex.y)
        }
        
        
        return ClosedShape(orderedVertices: flattened)
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
            
            
            let rotatedCube = cube.rotateAroundY(rotationCenter: cubeOrigin, angleRadians: yAngleRadians).rotateAroundX(rotationCenter: cubeOrigin, angleRadians: xAngleRadians)
            
            let shape = ClosedShape(orderedVertices: rotatedCube.vertices)
            
            let projection = renderer.render(shape3d: shape)
            
            let path = CGMutablePath()
            for (i, vertex) in projection.orderedVertices.enumerated() {
                let point = CGPoint(x: vertex.x, y: vertex.y)
                if (i == 0) {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            
            context.stroke(Path(path),
                           with: .color(.green),
                           lineWidth: 3)
        }
//        .frame(width: 300, height: 200)
        .focusable()
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged({ it in
                    print("Moust down")
                    
                    print("it.translation.height: \(it.translation.height)")
                    print("it.translation.width: \(it.translation.width)")
                    print("it.velocity.width: \(it.velocity.width)")
                    
                    
                    
                    xAngleRadians += it.translation.height/800
                    yAngleRadians += it.translation.width/800
                })
//                .onEnded({ it in
//                    print("Moust up")
//                    let distanceDragged = hypot(it.translation.width, it.translation.height)
//                    let dragDirection = atan2(it.location.x - it.startLocation.x, it.location.y - it.startLocation.y)
//                    print("distanceDragged: \(distanceDragged)")
//                    print("dragDirection: \(dragDirection)")
//                    
//                    xAngleRadians += it.translation.height/500
//                    yAngleRadians += it.translation.width/500
//                })
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
