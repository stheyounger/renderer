//
//  Triangle.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

struct Triangle<Point> {
    let orderedVertices: [Point]
    
    init(_ vertex1: Point, _ vertex2: Point, _ vertex3: Point) {
        self.orderedVertices = [vertex1, vertex2, vertex3]
    }
    
    init(orderedVertices: [Point]) {
        self.orderedVertices = orderedVertices
    }
    
    func centerPoint3d() -> Point3d? {
        if ((Point.self as? Point3d.Type) != nil) {
            let sumOfPoints = orderedVertices.reduce(Point3d(x: 0, y: 0, z: 0)) { acc, point in
                acc.plus(point as! Point3d)
            }
            
            return Point3d(x: (sumOfPoints.x)/3, y: (sumOfPoints.y)/3, z: (sumOfPoints.z)/3)
        } else {
            return nil
        }
    }
}
