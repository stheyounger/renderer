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
    
    
//    func moveInDirectionForDistance(direction: Vector, distance: Double) -> Point3d {
//        let origin = self
//        let directionAndDistance = direction.times(distance)
//        return Point3d(x: origin.x + directionAndDistance.i, y: origin.y + directionAndDistance.j, z: origin.z + directionAndDistance.k)
//    }
    
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

struct Vector {
    let dimensions: [Double]
    
    init(dimensions: [Double]) {
        self.dimensions = dimensions
    }
    init(_ point: Point3d) {
        dimensions = [point.x, point.y, point.z]
    }
    
    func times(_ scalar: Double) -> Vector {
        return Vector(dimensions: dimensions.map { dimension in
            dimension * scalar
        })
    }
    
    func plus(_ other: Vector) -> Vector {
        return Vector(dimensions: dimensions.enumerated().map { (i, dimension) in
            let otherDimension = other.dimensions[i]
            
            return dimension + otherDimension
        })
    }
    
    func minus(_ other: Vector) -> Vector {
        let otherNegated = other.dimensions.map{ dimension in -dimension }
        return plus(Vector(dimensions: otherNegated))
    }
    
    func magnitude() -> Double {
        return sqrt(dimensions.reduce(0, { (acc, dimension) in
            acc + pow(dimension, 2)
        }))
    }
    
    func normalize() -> Vector {
        let magnitude = magnitude()
        return Vector(dimensions: dimensions.map { dimension in
            dimension / magnitude
        })
    }
    
    func dot(_ other: Vector) -> Double {
        return dimensions.enumerated().reduce(0, { (acc, pair) in
            let i: Int = (pair.0)
            let dimension = (pair.1)
            
            let otherDimension = other.dimensions[i]
            
            return acc + (dimension * otherDimension)
        })
    }
    
    func cross(_ other: Vector) -> Vector {
        func nextDimension(i: Int) -> Int {
            if (i < dimensions.count-1) {
                i + 1
            } else {
                0
            }
        }
        
        let otherDimensions = other.dimensions
        
        return Vector(dimensions: (0...(dimensions.count-1)).map { i in
            let i2 = nextDimension(i: i)
            let i3 = nextDimension(i: i2)
            
            let vector1 = Vector(dimensions: [dimensions[i2], otherDimensions[i2]])
            let vector2 = Vector(dimensions: [dimensions[i3], otherDimensions[i3]])
            
            let dot = vector1.dot(vector2)
            print("i: \(i), dot: \(dot), a: \(vector1), b: \(vector2)")
            return dot
        })
    }
    
    func translated(matrixColumns: [[Double]]) -> Vector {
        return Vector(dimensions: matrixColumns.map { column in
            Vector(dimensions: column).dot(self)
        })
    }
}


struct Plane {
    
    let normalVector: Vector
    let pointOnPlane: Point3d
    
    init(normalVector: Vector, pointOnPlane: Point3d) {
        self.normalVector = normalVector.normalize()
        self.pointOnPlane = pointOnPlane
    }

    func findIntersectionOfLine(line: Line<Point3d>) -> Point3d {
        
        let lineOrigin = Vector(line.start)
        let lineDirection = (lineOrigin.minus(Vector(line.end))).normalize()
        
        let distanceToIntersection = (normalVector.dot(Vector(pointOnPlane)) - normalVector.dot(lineOrigin)) / normalVector.dot(lineDirection)
        
        let vectorToIntersection = lineOrigin.plus(lineDirection.times(distanceToIntersection))
        return Point3d(x: vectorToIntersection.dimensions[0], y: vectorToIntersection.dimensions[1], z: vectorToIntersection.dimensions[2])
    }
}

struct Renderer3d {
    
    struct Camera {
        let frameCenter: Point3d
        let focalPoint: Point3d
        let direction: Vector
        
        init(frameCenter: Point3d, direction: Vector, focalLength: Double) {
            self.frameCenter = frameCenter
            let vectorToFocalPoint = Vector(frameCenter).plus(direction.times(-focalLength))
            self.focalPoint = Point3d(x: vectorToFocalPoint.dimensions[0], y: vectorToFocalPoint.dimensions[1], z: vectorToFocalPoint.dimensions[2])
            self.direction = direction
        }
    }
    
    private func flatten(point: Point3d, camera: Camera) -> Point2d {
        let i = camera.direction
        let j = i.cross(Vector(dimensions: [0, 1, 0])).normalize()
        let k = j.cross(i).normalize()
        
        let vectorPoint = Vector(point)
        
        let flattenedPoint = vectorPoint.translated(matrixColumns: [j.dimensions, k.dimensions, i.dimensions])
        
        return Point2d(
            x: flattenedPoint.dimensions[0],
            y: flattenedPoint.dimensions[1]
        )
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> Point2d {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: camera.focalPoint, end: point))
        
        
        return flatten(point: intersectionPoint, camera: camera)
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
            
            let start2d = projectPoint(
                point: line.start,
                camera: camera
            )
            let end2d = projectPoint(
                point: line.end,
                camera: camera
            )
            
            let projectedLine = Line(start: start2d, end: end2d)
            
            print("line: \(line)")
            print("projectedLine: \(projectedLine)")
            
            return projectedLine
            
//            let theEntireLineIsBehindTheCamera = line.start.z < camera.frameCenter.z && line.end.z < camera.frameCenter.z
//            if (theEntireLineIsBehindTheCamera) {
//                 return nil
//            } else {
//                
//                func coercePointInFrontOfCamera(_ point: Point3d) -> Point3d {
//                    return Point3d(x: point.x, y: point.y, z: max(point.z, camera.frameCenter.z))
//                }
//                
//                let start2d = projectPoint(
//                    point: coercePointInFrontOfCamera(line.start),
//                    camera: camera
//                )
//                let end2d = projectPoint(
//                    point: coercePointInFrontOfCamera(line.end),
//                    camera: camera
//                )
//                
//                return Line(start: start2d, end: end2d)
//            }
        }
        
        return projected.filter { line in line != nil }.map { line in line! }
    }
}


struct ContentView: View {
    
    @State private var yAngleRadians = 0.0
    @State private var xAngleRadians = 0.0
    private let angleChangeRadians = Double.pi/20
    
    @State private var xPosition = 0.0
    @State private var yPosition = 0.0
    @State private var zPosition = 0.0
    private let movementAmount = 5.0
    
    var body: some View {
        
        let cubeOrigin = Point3d(x: 70, y: 10, z: 70)
        let cube = Cube(origin: cubeOrigin, sideLength: 30).polygonMesh
        let cube2 = Cube(origin: Point3d(x: 20, y: 10, z: 20), sideLength: 30).polygonMesh
        
        let renderer = Renderer3d()
        
        
        return Canvas { context, size in
            
            let vector1 = Vector(dimensions: [1, 2, 0])
            let vector2 = Vector(dimensions: [4, 4, 4])
            
            let cross = vector1.cross(vector2)
            print("cross: \(cross)")
            
            let camera = Renderer3d.Camera(frameCenter: Point3d(x: xPosition, y: yPosition, z: zPosition), direction: Vector(dimensions: [0,0,1]), focalLength: 50)
            
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
                default:
                    switch(press.modifiers) {
                    case EventModifiers.shift:
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
        }
    }
}

#Preview {
    ContentView()
}
