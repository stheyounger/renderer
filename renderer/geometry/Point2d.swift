//
//  Point2d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

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
    
    func plus(_ other: Point2d) -> Point2d {
        return Point2d(x: x+other.x, y: y+other.y)
    }
}
