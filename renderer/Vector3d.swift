//
//  Vector3d.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation


struct Vector3d {
    let dimensions: [Double]
    
    init(dimensions: [Double]) {
        self.dimensions = dimensions
    }
    init(_ point: Point3d) {
        dimensions = [point.x, point.y, point.z]
    }
    
    func times(_ scalar: Double) -> Vector3d {
        return Vector3d(dimensions: dimensions.map { dimension in
            dimension * scalar
        })
    }
    
    func plus(_ other: Vector3d) -> Vector3d {
        return Vector3d(dimensions: dimensions.enumerated().map { (i, dimension) in
            let otherDimension = other.dimensions[i]
            
            return dimension + otherDimension
        })
    }
    
    func minus(_ other: Vector3d) -> Vector3d {
        let otherNegated = other.dimensions.map{ dimension in -dimension }
        return plus(Vector3d(dimensions: otherNegated))
    }
    
    func magnitude() -> Double {
        return sqrt(dimensions.reduce(0, { (acc, dimension) in
            acc + pow(dimension, 2)
        }))
    }
    
    func normalize() -> Vector3d {
        let magnitude = magnitude()
        return Vector3d(dimensions: dimensions.map { dimension in
            dimension / magnitude
        })
    }
    
    func dot(_ other: Vector3d) -> Double {
        return dimensions.enumerated().reduce(0, { (acc, pair) in
            let i: Int = (pair.0)
            let dimension = (pair.1)
            
            let otherDimension = other.dimensions[i]
            
            return acc + (dimension * otherDimension)
        })
    }
    
    func cross(_ other: Vector3d) -> Vector3d {
        
        let otherDimensions = other.dimensions
        
        return Vector3d(dimensions: [
            (dimensions[1] * otherDimensions[2]) - (dimensions[2] * otherDimensions[1]),
            
            (dimensions[2] * otherDimensions[0]) - (dimensions[0] * otherDimensions[2]),
            
            (dimensions[0] * otherDimensions[1]) - (dimensions[1] * otherDimensions[0]),
        ])
    }
    
    func translated(matrixColumns: [[Double]]) -> Vector3d {
        return Vector3d(dimensions: matrixColumns.map { column in
            Vector3d(dimensions: column).dot(self)
        })
    }
    
    func toPoint3d() -> Point3d {
        return Point3d(x: dimensions[0], y: dimensions[1], z: dimensions[2])
    }
}
