//
//  Renderer3d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation
import SwiftUI


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
    let polygons: [Polygon<Point2d>]
    let color: Color
    
    init(polygons: [Polygon<Point2d>], color: Color) {
        self.polygons = polygons
        self.color = color
    }
}

struct Polygon<Point> {
    let orderedVertices: [Point]
    
    init(orderedVertices: [Point]) {
        self.orderedVertices = orderedVertices
    }
}

struct Renderer3d {
    
    private func flatten(point: Point3d, camera: Camera) -> Point2d {
        let direction = camera.direction
        let y = camera.verticalDirection
        let x = camera.horizontalDirection
        
        let vectorPoint = Vector3d(point)
        let flattenedPoint = vectorPoint.translated(matrixColumns: [x.dimensions, y.dimensions, direction.dimensions])
        print("intersectionWithCamera: \(vectorPoint)")
        print("flattenedPoint: \(flattenedPoint)")
        
        return Point2d(
            x: flattenedPoint.dimensions[0],
            y: flattenedPoint.dimensions[1]
        )
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> Point2d? {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let ray = Line(start: camera.focalPoint, end: point)
        
        let rayDirection = Vector3d(ray.start.minus(ray.end)).normalize()
        let pointIsInFrontOfTheCamera = camera.direction.dot(rayDirection) <= 0
        if (pointIsInFrontOfTheCamera) {
            
            let intersectionPoint = cameraPlane.findIntersectionOfLine(line: ray)
            
            
            if (intersectionPoint != nil) {
                
                let relativeToFrame = intersectionPoint!.minus(camera.frameCenter)
                
                let flattened = flatten(point: relativeToFrame, camera: camera)
                
                return flattened
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
    
    func render(camera: Camera, objects: [Surface3d]) -> [Surface2d] {
        
        let surfacesOrderedByDepth = objects.sorted(by: { A, B in
            
            func calcDepth(_ surface: Surface3d) -> Double {
                let sumOfCenters = surface.triangles.reduce(Point3d(x: 0, y: 0, z: 0)) { acc, triangle in
                    acc.plus(triangle.centerPoint3d()!)
                }
                
                let numberOfTriangles = Double(surface.triangles.count)
                let centerOfSurface = Point3d(x: sumOfCenters.x/numberOfTriangles, y: sumOfCenters.y/numberOfTriangles, z: sumOfCenters.z/numberOfTriangles)
                
                let distanceToCameraCenter = camera.frameCenter.distance(centerOfSurface)
                return distanceToCameraCenter
            }
            
            let aIsBeforeB = calcDepth(A) > calcDepth(B)
            
            return aIsBeforeB
        })
        
        return surfacesOrderedByDepth.map { object in
            
            let projection: [Polygon<Point2d>?] = object.triangles.map { triangle in
                let projectedPoints: [Point2d?] = triangle.orderedVertices.flatMap { point in
                    let firstTry = projectPoint(
                        point: point,
                        camera: camera
                    )
                    return firstTry
                    
//                    if (firstTry != nil) {
//                        return [firstTry]
//                    } else {
//                        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
//                        
//                        let otherPoints = triangle.orderedVertices.filter {it in
//                            it != point
//                        }
//                        
//                        return otherPoints.map { otherPoint in
//                            let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: point, end: otherPoint))
//                            
//                            if (intersectionPoint != nil) {
//                                let relativeToFrame = intersectionPoint!.minus(camera.frameCenter)
//                                
//                                let flattened = flatten(point: relativeToFrame, camera: camera)
//                                
//                                return flattened
//                            } else {
//                                return nil
//                            }
//                        }.filter({it in it != nil})
//                    }
                }
                
                if (!projectedPoints.contains(where: {point in point==nil})) {
                    let nonNullTriangle = Polygon(orderedVertices: projectedPoints.map { point in point! })
                    
                    return nonNullTriangle
                } else {
                    return nil
                }
            }
            
            let nullRemovedProjectedTriangles = projection.filter { line in line != nil }.map { line in line! }
            
            return Surface2d(polygons: nullRemovedProjectedTriangles, color: object.color)
        }
    }
}
