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
    
    func angleRadiansBetween(_ other: Vector3d) -> Double {
        return acos(self.dot(other) / (self.magnitude() * other.magnitude()))
    }
}

struct Matrix2x2 {
    let columns: [[Double]]
    
    init(_ columns: [[Double]]) {
        self.columns = columns
    }
    
    func determinant() -> Double {
        return (columns[0][0] * columns[1][1]) - (columns[1][0] * columns[0][1])
    }
}

struct Matrix3x3 {
    let columns: [[Double]]
    
    init(_ columns: [[Double]]) {
        self.columns = columns
    }
    
    func determinant() -> Double {
        let a = columns[0][0] * Matrix2x2([Array(columns[1].dropFirst()), Array(columns[2].dropFirst())]).determinant()
        
        let b = columns[1][0] * Matrix2x2([Array(columns[0].dropFirst()), Array(columns[2].dropFirst())]).determinant()
        
        let c = columns[2][0] * Matrix2x2([Array(columns[0].dropFirst()), Array(columns[1].dropFirst())]).determinant()
        
        return a - b + c
    }
    
    private func columnTimes(_ column: [Double], _ scalar: Double) -> [Double] {
        return column.map { it in
            it * scalar
        }
    }
    
    private func columnDrop(_ column: [Double], _ index: Int) -> [Double] {
        return column.enumerated().filter { i, it in
            i != index
        }.map{i, it in it}
    }
    
    func inverse() -> Matrix3x3 {
        return Matrix3x3((0...2).map { i in
            columnTimes(
                [Matrix2x2([ columnDrop(columns[1], i), columnDrop(columns[2], i) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[2], i), columnDrop(columns[0], i) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[0], i), columnDrop(columns[1], i) ]).determinant()],
                1/determinant()
            )
        })
    }
}
