//
//  Renderer3d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation
import SwiftUI


struct RenderedPoint {
    let point: Point2d
    let depth: Double
    
    init(point: Point2d, depth: Double) {
        self.point = point
        self.depth = depth
    }
}

struct Surface2d {
    let triangles: [Triangle<RenderedPoint>]
    let color: Color
    
    init(triangles: [Triangle<RenderedPoint>], color: Color) {
        self.triangles = triangles
        self.color = color
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
        let depth: Double
        
        init(point: Point2d?, dotProduct: Double, depth: Double) {
            self.point = point
            self.dotProduct = dotProduct
            self.depth = depth
        }
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> ProjectedPoint {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let ray = Line(start: camera.focalPoint, end: point)
        
        let intersectionPoint: Point3d? = cameraPlane.findIntersectionOfLine(line: ray)
        
        let flattened: Point2d?;
        if (intersectionPoint != nil) {
            let relativeToFrame = intersectionPoint!.minus(camera.frameCenter)
            
            flattened = flatten(point: relativeToFrame, camera: camera)
        } else {
            flattened = nil
        }
        
        let rayDirection = Vector3d(ray.start.minus(ray.end)).normalize()
        
        return ProjectedPoint(
            point: flattened,
            dotProduct: camera.direction.dot(rayDirection),
            depth: camera.frameCenter.distance(point)
        )
    }
    
    private func makeUpInfinitelyFarPoints(projectedPoint: ProjectedPoint, projectedPoints: [ProjectedPoint], distanceToOffscreen: Double) -> [RenderedPoint] {
        let point = projectedPoint.point
        return projectedPoints.compactMap { otherProjectedPoint in
            let otherPoint = otherProjectedPoint.point
            
            if (otherProjectedPoint.dotProduct < 0) {
                if (otherPoint != point) {
                    let rayDirection = Vector2d(otherPoint!.minus(point!)).normalize()
                    
                    let vectorFromOtherToFalselyProjected = rayDirection.times(distanceToOffscreen)
                    
                    return RenderedPoint(
                        point: vectorFromOtherToFalselyProjected.toPoint2d().plus(otherPoint!),
                        depth: otherProjectedPoint.depth
                    )
                } else {
                    return nil as RenderedPoint?
                }
            } else if (otherProjectedPoint.dotProduct > 0) {
                return nil as RenderedPoint?
            } else {
                return nil as RenderedPoint?
            }
        }
    }
    
    private func renderTriangle(triangle: Triangle<Point3d>, camera: Camera) -> [Triangle<RenderedPoint>]? {
        
        let numberOfVerticesInFrame = triangle.orderedVertices.reduce(0, { acc, point in
            if (isPointInFrontOfCamera(point: point, camera: camera)) {
                return acc + 1
            } else {
                return acc
            }
        })
        
        let anyVerticesAreInFrame = numberOfVerticesInFrame > 0
        if (anyVerticesAreInFrame) {
            
            let projectedPoints = triangle.orderedVertices.map { point in
                return projectPoint(
                    point: point,
                    camera: camera
                )
            }
            
            let allVerticesAreInFrame = numberOfVerticesInFrame == 3
            if (allVerticesAreInFrame) {
                return [Triangle(orderedVertices: projectedPoints.map { projectedPoint in RenderedPoint(point: projectedPoint.point!, depth: projectedPoint.depth) })]
            } else {
                
                let incorrectlyProjectedPoints = projectedPoints.filter { projectedPoint in
                    projectedPoint.dotProduct >= 0
                }
                let correctlyProjectedPoints = projectedPoints.filter { projectedPoint in
                    projectedPoint.dotProduct < 0
                }
                print("number of incorrectlyProjectedPoints: \(incorrectlyProjectedPoints.count)")
                return incorrectlyProjectedPoints.map { incorrectlyProjectedPoint in
                    let fixedPoints = makeUpInfinitelyFarPoints(
                        projectedPoint: incorrectlyProjectedPoint,
                        projectedPoints: projectedPoints,
                        distanceToOffscreen: hypot(camera.frameWidth, camera.frameHeight) * 2
                    )
                    
                    return Triangle(orderedVertices: fixedPoints + correctlyProjectedPoints.map { projectedPoint in RenderedPoint(point: projectedPoint.point!, depth: projectedPoint.depth) })
                }
            }
        } else {
            return nil
        }
    }
    
    func render(camera: Camera, objects: [Surface3d]) -> [Surface2d] {
        return objects.map { object in
            let renderedTriangles: [Triangle<RenderedPoint>] = object.triangles.compactMap { triangle in
                renderTriangle(triangle: triangle, camera: camera)
            }.flatMap { $0 }
            
            return Surface2d(triangles: renderedTriangles, color: object.color)
        }
    }
}
