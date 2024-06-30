//
//  Plane.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

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
        
        print("distanceToIntersection: \(distanceToIntersection)")
        
        let vectorToIntersection = lineOrigin.plus(lineDirection.times(distanceToIntersection))
        
        return Point3d(x: vectorToIntersection.dimensions[0], y: vectorToIntersection.dimensions[1], z: vectorToIntersection.dimensions[2])
    }
}
