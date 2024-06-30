//
//  Point2d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

struct Point2d: Equatable {
    let x: Double
    let y: Double

    init(x: Double, y: Double) {
        self.x = x
        self.y = y
    }
    
    func angleRadians(_ point: Point2d) -> Double {
        return atan2(y - point.y, x - point.x)
    }
    
    func times(_ number: Double) -> Point2d {
        return Point2d(x: x * number, y: y * number)
    }
    
    func plus(_ other: Point2d) -> Point2d {
        return Point2d(x: x+other.x, y: y+other.y)
    }
    func minus(_ other: Point2d) -> Point2d {
        return plus(other.times(-1))
    }
}
