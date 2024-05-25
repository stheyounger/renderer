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
    
    func angleRadians(_ point: Point2d) -> Double {
        return atan2(y - point.y, x - point.x)
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
    
    
    func moveInDirectionForDistance(direction: UnitVector3d, distance: Double) -> Point3d {
        let origin = self
        let directionAndDistance = direction.times(scalar: distance)
        return Point3d(x: origin.x + directionAndDistance.i, y: origin.y + directionAndDistance.j, z: origin.z + directionAndDistance.k)
    }
    
    func dimension(_ index: Int) -> Double {
        return [x, y, z][min(index, 2)]
    }
    
    func distance(_ point: Point3d) -> Double {
        return sqrt( pow(x-point.x, 2) + pow(y-point.y, 2) + pow(z-point.z, 2) )
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

struct UnitVector3d {
    let i: Double
    let j: Double
    let k: Double
    
    init(i: Double, j: Double, k: Double) {
        self.i = i
        self.j = j
        self.k = k
    }
    
    func times(scalar: Double) -> UnitVector3d {
        return UnitVector3d(i: i * scalar, j: j * scalar, k: k * scalar)
    }
}

struct Plane {
    
    let normalVector: UnitVector3d
    let pointOnPlane: Point3d
    
    init(normalVector: UnitVector3d, pointOnPlane: Point3d) {
        self.normalVector = normalVector
        self.pointOnPlane = pointOnPlane
    }
}

struct Renderer3d {
    
    struct Camera {
        let focalPoint: Point3d
        let frameCenter: Point3d
        
        init(focalPoint: Point3d, frameCenter: Point3d) {
            self.focalPoint = focalPoint
            self.frameCenter = frameCenter
        }
    }
    
    func findIntersectionOfPlaneAndLine(plane: Plane, line: Line<Point3d>) -> Point3d {
        
        let f = line.start
        let p = line.end
        let b = plane.pointOnPlane
        let v = Point3d(x: plane.normalVector.i, y: plane.normalVector.j, z: plane.normalVector.k)
        
        print("f: \(f)")
        print("p: \(p)")
        print("b: \(b)")
        print("v: \(v)")
        
        func dimension(dimensionIndex: Int) -> Double {
            
            func nextDimensionIndex(i: Int) -> Int {
                return if (i < 2) {
                    i + 1
                } else {
                    0
                }
            }
            
            let i = dimensionIndex
            let i2 = nextDimensionIndex(i: i)
            let i3 = nextDimensionIndex(i: i2)
            
            let repeated = ( ((p.dimension(i2) - f.dimension(i2))*v.dimension(i2) + (p.dimension(i3) - f.dimension(i3))*v.dimension(i3)) / ((p.dimension(i) - f.dimension(i))*v.dimension(i)) )
            
            return (( f.dimension(i) * repeated ) - ( ((f.dimension(i2) - b.dimension(i2))*v.dimension(i2) + (f.dimension(i3) - b.dimension(i3))*v.dimension(i3)) / v.dimension(i) ) + b.dimension(i) ) / (1 + repeated)
        }
        
        return Point3d(
            x: dimension(dimensionIndex: 0),
            y: dimension(dimensionIndex: 1),
            z: dimension(dimensionIndex: 2)
        )
    }
    
    private func calcIntersectionBetween(line: Line<Point3d>, planeY: Double) -> Point2d {
        let pointA = line.end
        let pointB = line.start
        
        let something = (planeY - pointA.y)/(pointB.y - pointA.y)
        
        let intersection = Point2d(
            x: (something*(pointB.x - pointA.x)) + pointA.x,
            y: (something*(pointB.z - pointA.z)) + pointA.z
//            x: (((planeY - pointA.y)*(pointB.x - pointA.x))/(pointB.y - pointA.y)) + pointA.x,
//            y: (((planeY - pointA.y)*(pointB.z - pointA.z))/(pointB.y - pointA.y)) + pointA.z
        )
        
        return intersection
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> Point2d {
        
        let projectedX = calcIntersectionBetween(line: Line(start: camera.focalPoint, end: point), planeY: camera.frameCenter.y)
        
        return projectedX
        
//        return Point2d(
//                x: point.x - camera.frameCenter.x,
//                y: point.y - camera.frameCenter.y)
    }
    
    func render(camera: Camera, shapes: [PolygonMesh]) -> [Line<Point2d>] {
        
        let wireframe = shapes.flatMap { shape in
            shape.triangles.flatMap { triangle in
                triangle.orderedVertices.flatMap { vertex in
                    triangle.orderedVertices.map { otherVertex in
                        Line(start: vertex, end: otherVertex)
                    }
                }
            }
        }
        
        
        let projected: [Line<Point2d>?] = wireframe.map { line in
            
            let theEntireLineIsBehindTheCamera = line.start.z < camera.frameCenter.z && line.end.z < camera.frameCenter.z
            if (theEntireLineIsBehindTheCamera) {
                 return nil
            } else {
                
                func coercePointInFrontOfCamera(_ point: Point3d) -> Point3d {
                    return Point3d(x: point.x, y: point.y, z: max(point.z, camera.frameCenter.z))
                }
                
                let start2d = projectPoint(
                    point: coercePointInFrontOfCamera(line.start),
                    camera: camera
                )
                let end2d = projectPoint(
                    point: coercePointInFrontOfCamera(line.end),
                    camera: camera
                )
                
                return Line(start: start2d, end: end2d)
            }
        }
        
        return projected.filter { line in line != nil }.map { line in line! }
    }
}


struct ContentView: View {
    
    @State private var yAngleRadians = 0.0
    @State private var xAngleRadians = 0.0
    private let angleChangeRadians = Double.pi/20
    
    var body: some View {
    
        
        let cubeOrigin = Point3d(x: 70, y: 10, z: 70)
        let cube = Cube(origin: cubeOrigin, sideLength: 30).polygonMesh
        let cube2 = Cube(origin: Point3d(x: 20, y: 10, z: 20), sideLength: 30).polygonMesh
        
        let camera = Renderer3d.Camera(focalPoint: Point3d(x: -10, y: -100, z: -10),
                                       frameCenter: Point3d(x: -10, y: 0, z: -10))
        let renderer = Renderer3d()
        
        let cameraCenter = Point3d(x: 1/4, y: 1, z: 0)
        let cameraDirection = UnitVector3d(i: 1/3, j: 1.5/3, k: 0.5/3)
        let focalLength = 2
        let focalPoint = cameraCenter.moveInDirectionForDistance(direction: cameraDirection, distance: -Double(focalLength))
        let intersection = renderer.findIntersectionOfPlaneAndLine(
            plane: Plane(normalVector: cameraDirection, pointOnPlane: cameraCenter),
            line: Line(start: focalPoint, end: Point3d(x: 2, y: 2, z: 2))   
        )
        
        return Canvas { context, size in
            
            print("focalPoint: \(focalPoint))")
            print("intersection: \(intersection))")
            
            let rotatedCube = cube.rotateAroundY(rotationCenter: cubeOrigin, angleRadians: yAngleRadians).rotateAroundX(rotationCenter: cubeOrigin, angleRadians: xAngleRadians)
            
            let projection = renderer.render(camera: camera, shapes: [rotatedCube, cube2])
            
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
