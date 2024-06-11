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
        
        let vectorPoint = Vector3d(point)
        
        let flattenedPoint = vectorPoint.translated(matrixColumns: [x.dimensions, y.dimensions, direction.dimensions])
        
        return Point2d(
            x: flattenedPoint.dimensions[0],
            y: flattenedPoint.dimensions[1]
        )
    }
    
    private func projectPoint(point: Point3d, camera: Camera) -> Point2d? {
        
        let cameraPlane = Plane(normalVector: camera.direction, pointOnPlane: camera.frameCenter)
        
        let intersectionPoint = cameraPlane.findIntersectionOfLine(line: Line(start: camera.focalPoint, end: point))
        
        if (intersectionPoint != nil) {
            let flattened = flatten(point: intersectionPoint!, camera: camera)
            
            return flattened
        } else {
            return nil
        }
    }
    
    func render(camera: Camera, objects: [Surface3d]) -> [Surface2d] {
        return objects.map { object in
//            let wireframe: [Line<Point3d>] = object.triangles.flatMap { triangle in
//                triangle.orderedVertices.flatMap { vertex in
//                    triangle.orderedVertices.map { otherVertex in
//                        Line(start: vertex, end: otherVertex)
//                    }
//                }
//            }
            
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
                
//                let start2d = projectPoint(
//                    point: line.start,
//                    camera: camera
//                )
//                let end2d = projectPoint(
//                    point: line.end,
//                    camera: camera
//                )
                
//                if (start2d != nil && end2d != nil) {
//                    let projectedLine = Line(start: start2d!, end: end2d!)
//                    
//                    func pointIsOutsideFrame(_ point: Point2d, _ camera: Camera) -> Bool {
//                        let xIsOutOfFrame = abs(point.x) > camera.frameWidth/2
//                        let yIsOutOfFrame = abs(point.y) > camera.frameHeight/2
//                        return xIsOutOfFrame || yIsOutOfFrame
//                    }
//                    func getPointInsideFrame(_ point: Point2d, _ otherPoint: Point2d, _ camrea: Camera) -> Point2d {
//                        let vectorPoint = Vector3d(dimensions: [point.x, point.y, 0])
//                        let vectorOtherPoint = Vector3d(dimensions: [otherPoint.x, otherPoint.y, 0])
//                        let lineAsVector = vectorPoint.minus(vectorOtherPoint).normalize()
//                        
//                        let slope = lineAsVector.dimensions[1] / lineAsVector.dimensions[0]
//                        
//                        return Point2d(
//                            x: camera.frameWidth/2 * (1/slope),
//                            y: camera.frameHeight/2 * slope
//                        )
//                    }
//                    return projectedLine
//                    
////                    if (pointIsOutsideFrame(projectedLine.end, camera)) {
////                        Line(start: projectedLine.start, end: getPointInsideFrame(projectedLine.start, projectedLine.end, camera))
////                    } else if (pointIsOutsideFrame(projectedLine.start, camera)) {
////                        Line(start: getPointInsideFrame(projectedLine.end, projectedLine.start, camera), end: projectedLine.end)
////                    } else {
////                        projectedLine
////                    }
//                } else {
//                    return nil
//                }
            }
            
            let nullRemovedProjectedTriangles = projection.filter { line in line != nil }.map { line in line! }
            
            return Surface2d(triangles: nullRemovedProjectedTriangles, color: object.color)
        }
    }
}
