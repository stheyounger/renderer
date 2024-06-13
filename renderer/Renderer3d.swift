//
//  Renderer3d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation
import SwiftUI

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
    
    func centerPoint2d() -> Point2d {
        let sumOfPoints = orderedVertices.reduce(Point2d(x: 0, y: 0)) { acc, point in
            acc.plus(point as! Point2d)
        }
        let numberOfPoints = Double(orderedVertices.count)
        
        return Point2d(x: (sumOfPoints.x)/numberOfPoints, y: (sumOfPoints.y)/numberOfPoints)
    }
    
    func reorderVertices() -> Polygon<Point2d> {
        let unorderedVertices: [Point2d] = orderedVertices.map { point in
                point as! Point2d
        }
        
        let centerOfPolygon = centerPoint2d()
        
        return Polygon<Point2d>(orderedVertices: unorderedVertices.sorted(by: { a, b in
            
            let angleToA = centerOfPolygon.angleRadians(a)
            let angleToB = centerOfPolygon.angleRadians(b)
            
            let aGoesBeforeB = angleToA < angleToB
            return aGoesBeforeB
        }))
        
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
                    
                    if (firstTry != nil) {
                        return [firstTry]
                    } else {
                        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
                        
                        let otherPoints = triangle.orderedVertices.filter {it in
                            it != point
                        }
                        
                        return otherPoints.map { otherPoint in
                            let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: point, end: otherPoint))
                            
                            if (intersectionPoint != nil) {
                                let relativeToFrame = intersectionPoint!.minus(camera.frameCenter)
                                
                                let flattened = flatten(point: relativeToFrame, camera: camera)
                                
                                return flattened
                            } else {
                                return nil
                            }
                        }.filter({it in it != nil})
                    }
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
