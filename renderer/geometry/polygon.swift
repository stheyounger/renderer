//
//  polygon.swift
//  renderer
//
//  Created by James Penrose on 7/1/24.
//

import Foundation

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
