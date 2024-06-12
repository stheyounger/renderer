//
//  Renderer3d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation
import SwiftUI


struct Renderer3d {
    
    private func flatten(point: Point3d, camera: Camera) -> Point2d {
        let direction = camera.direction
        let y = Vector3d(Point3d(x: 0, y: 1, z: 0))
        let x = direction.cross(y).normalize()
        print("direction: \(direction)")
        print("vy: \(y)")
        print("vx: \(x)")
        
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
        
        let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: camera.focalPoint, end: point))
        
        if (intersectionPoint != nil) {
            
            let relativeToFrame = intersectionPoint!.minus(camera.frameCenter)
            
            let flattened = flatten(point: relativeToFrame, camera: camera)
            
            return flattened
        } else {
            return nil
        }
    }
    
    func render(camera: Camera, objects: [Surface3d]) -> [Surface2d] {
        return objects.map { object in
            
            let projection: [Triangle<Point2d>?] = object.triangles.map { triangle in
                let projectedPoints = triangle.orderedVertices.map { point in
                    projectPoint(
                        point: point,
                        camera: camera
                    )
                }
                
                if (!projectedPoints.contains(where: {point in point==nil})) {
                    let nonNullTriangle = Triangle(orderedVertices: projectedPoints.map { point in point! })
                    
                    return nonNullTriangle
                } else {
                    return nil
                }
            }
            
            let nullRemovedProjectedTriangles = projection.filter { line in line != nil }.map { line in line! }
            
            return Surface2d(triangles: nullRemovedProjectedTriangles, color: object.color)
        }
    }
}
