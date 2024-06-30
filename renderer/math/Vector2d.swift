//
//  Vector2d.swift
//  renderer
//
//  Created by James Penrose on 6/29/24.
//

import Foundation

struct Vector2d {
    let dimensions: [Double]
    
    init(dimensions: [Double]) {
        self.dimensions = dimensions
    }
    init(_ point: Point2d) {
        dimensions = [point.x, point.y]
    }
    
    func times(_ scalar: Double) -> Vector2d {
        return Vector2d(dimensions: dimensions.map { dimension in
            dimension * scalar
        })
    }
    
    func plus(_ other: Vector2d) -> Vector2d {
        return Vector2d(dimensions: dimensions.enumerated().map { (i, dimension) in
            let otherDimension = other.dimensions[i]
            
            return dimension + otherDimension
        })
    }
    
    func minus(_ other: Vector2d) -> Vector2d {
        let otherNegated = other.dimensions.map{ dimension in -dimension }
        return plus(Vector2d(dimensions: otherNegated))
    }
    
    func magnitude() -> Double {
        return sqrt(dimensions.reduce(0, { (acc, dimension) in
            acc + pow(dimension, 2)
        }))
    }
    
    func normalize() -> Vector2d {
        let magnitude = magnitude()
        return Vector2d(dimensions: dimensions.map { dimension in
            dimension / magnitude
        })
    }
    
    func dot(_ other: Vector2d) -> Double {
        return dimensions.enumerated().reduce(0, { (acc, pair) in
            let i: Int = (pair.0)
            let dimension = (pair.1)
            
            let otherDimension = other.dimensions[i]
            
            return acc + (dimension * otherDimension)
        })
    }
    
    func toPoint2d() -> Point2d {
        return Point2d(x: dimensions[0], y: dimensions[1])
    }
    
    func angleRadiansBetween(_ other: Vector2d) -> Double {
        return acos(self.dot(other) / (self.magnitude() * other.magnitude()))
    }
}
