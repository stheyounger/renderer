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
    
    private func isPointInFrontOfCamera(point: Point3d, camera: Camera) -> Bool {
        let ray = Line(start: camera.focalPoint, end: point)
        
        let rayDirection = Vector3d(ray.start.minus(ray.end)).normalize()
        
        let pointIsInFrontOfFocalPoint = camera.direction.dot(rayDirection) < 0
        
        return pointIsInFrontOfFocalPoint
    }
    
    struct ProjectedPoint {
        let point: Point2d?
        let dotProduct: Double
        
        init(point: Point2d?, dotProduct: Double) {
            self.point = point
            self.dotProduct = dotProduct
        }
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> ProjectedPoint {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let ray = Line(start: camera.focalPoint, end: point)
        
        let intersectionPoint: Point3d? = cameraPlane.findIntersectionOfLine(line: ray)
        let flattened: Point2d? = if (intersectionPoint != nil) {
            flatten(point: intersectionPoint!, camera: camera)
        } else {
            nil
        }
        
        let rayDirection = Vector3d(ray.start.minus(ray.end)).normalize()
        
        return ProjectedPoint(
            point: flattened,
            dotProduct: camera.direction.dot(rayDirection)
        )
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
            
            
            let trianglesInFrame: [Triangle<Point3d>] = object.triangles.compactMap { triangle in
                
                let triangleIsInFrame = triangle.orderedVertices.reduce(false, { acc, point in
                    return acc || isPointInFrontOfCamera(point: point, camera: camera)
                })
                
                return if (triangleIsInFrame) {
                    triangle
                } else {
                    nil as Triangle<Point3d>?
                }
            }
            
            let projection: [Triangle<ProjectedPoint>] = trianglesInFrame.map { triangle in
                Triangle(orderedVertices: triangle.orderedVertices.map { point in
                    return projectPoint(
                        point: point,
                        camera: camera
                    )
                })
            }
            
            let asdf: [Polygon] = projection.map { triangleOfProjectedPoints in
                
                let polygonPoints: [Point2d] = triangleOfProjectedPoints.orderedVertices.flatMap { projectedPoint in
                    let point = projectedPoint.point
                    
                    if (projectedPoint.dotProduct < 0) {
                        return [point!]
                    } else if (projectedPoint.dotProduct > 0) {
                        return triangleOfProjectedPoints.orderedVertices.compactMap { otherProjectedPoint in
                            let otherPoint = otherProjectedPoint.point
                            if (otherPoint == point) {
                                return nil as Point2d?
                            } else {
                                let rayDirection = Vector2d(otherPoint!.minus(point!)).normalize()
                                
                                let largestDistanceOnScreen = hypot(camera.frameWidth, camera.frameHeight)
                                
                                let vectorFromOtherToFalselyProjected = rayDirection.times(largestDistanceOnScreen)
                                
                                return vectorFromOtherToFalselyProjected.toPoint2d().plus(otherPoint!)
                            }
                        }
                    } else {
                        return [Point2d(x: 0, y: 0)]
                    }
                }
                
                return Polygon(orderedVertices: polygonPoints)
            }
            
            return Surface2d(polygons: asdf, color: object.color)
            
//            let projection: [Polygon<Point2d>] = object.triangles.compactMap { triangle in
//                
//                let triangleIsInFrame = triangle.orderedVertices.reduce(false, { acc, point in
//                    return acc || isPointInFrontOfCamera(point: point, camera: camera)
//                })
//                
//                if (triangleIsInFrame) {
//                    let projectedPoints = triangle.orderedVertices.map { point in
//                        return projectPoint(
//                            point: point,
//                            camera: camera
//                        )
//                    }
//                    
//                    let polygonPoints: [Point2d] = projectedPoints.flatMap { projectedPoint in
//                        let point = projectedPoint.point
//                        
//                        return if (projectedPoint.dotProduct < 0) {
//                            [point!]
//                        } else if (projectedPoint.dotProduct > 0) {
//                            projectedPoints.compactMap { otherProjectedPoint in
//                                let otherPoint = otherProjectedPoint.point
//                                if (otherPoint == point) {
//                                    nil as Point2d?
//                                } else {
//                                    let rayDirection = Vector2d(otherPoint!.minus(point!)).normalize()
//                                    
//                                    let largestDistanceOnScreen = hypot(camera.frameWidth, camera.frameHeight)
//                                    
//                                    let vectorFromOtherToFalselyProjected = rayDirection.times(largestDistanceOnScreen)
//                                    
//                                    vectorFromOtherToFalselyProjected.toPoint2d().plus(otherPoint!)
//                                }
//                            }
//                        } else {
//                            [Point2d(x: 0, y: 0)]
//                        }
//                    }
//                    
//                    return Polygon(orderedVertices: polygonPoints)
//                } else {
//                    return nil
//                }
//            }
//            
//            return Surface2d(polygons: projection, color: object.color)
        }
    }
}
