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

struct Vector3d {
    let dimensions: [Double]
    
    init(dimensions: [Double]) {
        self.dimensions = dimensions
    }
    init(_ point: Point3d) {
        dimensions = [point.x, point.y, point.z]
    }
    
    func times(_ scalar: Double) -> Vector3d {
        return Vector3d(dimensions: dimensions.map { dimension in
            dimension * scalar
        })
    }
    
    func plus(_ other: Vector3d) -> Vector3d {
        return Vector3d(dimensions: dimensions.enumerated().map { (i, dimension) in
            let otherDimension = other.dimensions[i]
            
            return dimension + otherDimension
        })
    }
    
    func minus(_ other: Vector3d) -> Vector3d {
        let otherNegated = other.dimensions.map{ dimension in -dimension }
        return plus(Vector3d(dimensions: otherNegated))
    }
    
    func magnitude() -> Double {
        return sqrt(dimensions.reduce(0, { (acc, dimension) in
            acc + pow(dimension, 2)
        }))
    }
    
    func normalize() -> Vector3d {
        let magnitude = magnitude()
        return Vector3d(dimensions: dimensions.map { dimension in
            dimension / magnitude
        })
    }
    
    func dot(_ other: Vector3d) -> Double {
        return dimensions.enumerated().reduce(0, { (acc, pair) in
            let i: Int = (pair.0)
            let dimension = (pair.1)
            
            let otherDimension = other.dimensions[i]
            
            return acc + (dimension * otherDimension)
        })
    }
    
    func cross(_ other: Vector3d) -> Vector3d {
        
        let otherDimensions = other.dimensions
        
        return Vector3d(dimensions: [
            (dimensions[1] * otherDimensions[2]) - (dimensions[2] * otherDimensions[1]),
            
            (dimensions[2] * otherDimensions[0]) - (dimensions[0] * otherDimensions[2]),
            
            (dimensions[0] * otherDimensions[1]) - (dimensions[1] * otherDimensions[0]),
        ])
    }
    
    func translated(matrixColumns: [[Double]]) -> Vector3d {
        return Vector3d(dimensions: matrixColumns.map { column in
            Vector3d(dimensions: column).dot(self)
        })
    }
}


struct Plane {
    
    let normalVector: Vector3d
    let pointOnPlane: Point3d
    
    init(normalVector: Vector3d, pointOnPlane: Point3d) {
        self.normalVector = normalVector.normalize()
        self.pointOnPlane = pointOnPlane
    }

    func findIntersectionOfLine(line: Line<Point3d>) -> Point3d? {
        let lineOrigin = Vector3d(line.start)
        let lineDirection = (lineOrigin.minus(Vector3d(line.end))).normalize()
        
        let distanceToIntersection = (normalVector.dot(Vector3d(pointOnPlane)) - normalVector.dot(lineOrigin)) / normalVector.dot(lineDirection)
        
        let lineLength = line.start.distance(line.end)
        if (abs(distanceToIntersection) > abs(lineLength)) {
            return nil
        } else {
            let vectorToIntersection = lineOrigin.plus(lineDirection.times(distanceToIntersection))
            
            return Point3d(x: vectorToIntersection.dimensions[0], y: vectorToIntersection.dimensions[1], z: vectorToIntersection.dimensions[2])
        }
    }
}

struct Renderer3d {
    
    struct Camera {
        let frameCenter: Point3d
        let focalPoint: Point3d
        let direction: Vector3d
        let frameWidth: Double
        let frameHeight: Double
        
        init(
            frameCenter: Point3d,
            direction: Vector3d,
            focalLength: Double,
            frameWidth: Double,
            frameHeight: Double
        ) {
            self.frameCenter = frameCenter
            let vectorToFocalPoint = Vector3d(frameCenter).plus(direction.times(-focalLength))
            self.focalPoint = Point3d(
                x: vectorToFocalPoint.dimensions[0],
                y: vectorToFocalPoint.dimensions[1],
                z: vectorToFocalPoint.dimensions[2]
            )
            self.direction = direction.normalize()
            
            self.frameWidth = frameWidth
            self.frameHeight = frameHeight
        }
    }
    
    private func flatten(point: Point3d, camera: Camera) -> Point2d {
        let i = camera.direction
        let j = i.cross(Vector3d(dimensions: [0, 1, 0])).normalize().times(-1)
        let k = j.cross(i).normalize().times(-1)
        
        let vectorPoint = Vector3d(point)
        
        let flattenedPoint = vectorPoint.translated(matrixColumns: [j.dimensions, k.dimensions, i.dimensions])
        
        return Point2d(
            x: flattenedPoint.dimensions[0],
            y: flattenedPoint.dimensions[1]
        )
    }
    
    private func constrainInFrame(point: Point2d, camera: Camera) -> Point2d {
        let x = point.x
        let y = point.y
        
        func sign(_ n: Double) -> Double {
            return (n < 0 ? -1 : 1)
        }
        
        let inFrame = Point2d(
            x: min(abs(x), camera.frameWidth/2) * sign(x),
            y: min(abs(y), camera.frameHeight/2) * sign(y)
        )
        print("inFrame: \(inFrame)")
        return inFrame
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> Point2d? {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: camera.focalPoint, end: point))
        
        if (intersectionPoint != nil) {
            let flattened = flatten(point: intersectionPoint!, camera: camera)
            
            return constrainInFrame(point: flattened, camera: camera)
        } else {
            return nil
        }
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
            
            if (start2d != nil && end2d != nil) {
                let projectedLine = Line(start: start2d!, end: end2d!)
                return projectedLine
            } else {
                return nil
            }
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
    private let movementAmount = 0.1
    
    var body: some View {
        
        let cubeOrigin = Point3d(x: 0, y: 0, z: 1.5)
        let cube = Cube(origin: cubeOrigin, sideLength: 1).polygonMesh
        let cube2 = Cube(origin: Point3d(x: 5, y: 0, z: 2), sideLength: 1).polygonMesh
        let origin = PolygonMesh(triangles: [
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
        ])
        
        let renderer = Renderer3d()
        
        return Canvas { context, size in
            
            let camera = Renderer3d.Camera(
                frameCenter: Point3d(x: xPosition, y: yPosition, z: zPosition),
                direction: Vector3d(dimensions: [0,0,1]),
                focalLength: 0.707106,
                frameWidth: 1,
                frameHeight: 1
            )
            print("camera center: \(camera.frameCenter)")
            print("camera focal point: \(camera.focalPoint)")
            
            let rotatedCube = cube
            
            let rendering = renderer.render(camera: camera, shapes: [
                rotatedCube,
                cube2,
                origin
            ])
            
            let centered: [Line<Point2d>] = rendering.map{ line in
                
                func centerPoint(_ point: Point2d) -> Point2d {
                    let centerX = size.width/2
                    let centerY = size.height/2
                    
                    let flippedY = point.y * -1
                    
                    return Point2d(
                        x: point.x + centerX,
                        y: flippedY + centerY
                    )
                }
                
                let smallSideOfWindow = min(size.width, size.height)
                let smallSideOfCamera = min(camera.frameWidth, camera.frameHeight)
                
                let cameraToWindowConversion = smallSideOfWindow/smallSideOfCamera
                
                print("cameraToWindowConversion: \(cameraToWindowConversion)")
                func stretched(_ point: Point2d) -> Point2d {
                    let stretched = Point2d(x: point.x * cameraToWindowConversion, y: point.y * cameraToWindowConversion)
                    
                    print("preStretch: \(point) postStretch: \(stretched)")
                    
                    return stretched
                }
                
                func adjustToWindow(_ point: Point2d) -> Point2d {
                    return centerPoint(stretched(point))
                }
                
                return Line(
                    start: adjustToWindow(line.start),
                    end: adjustToWindow(line.end)
                )
            }
            
            let path = CGMutablePath()
            for (i, line) in centered.enumerated() {
                
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
        }
    }
}

#Preview {
    ContentView()
}
