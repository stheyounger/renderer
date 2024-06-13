//
//  Matrix.swift
//  renderer
//
//  Created by James Penrose on 6/12/24.
//

import Foundation

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
        
        return (a - b) + c
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
        return Matrix3x3([
            columnTimes(
                [Matrix2x2([ columnDrop(columns[1], 0), columnDrop(columns[2], 0) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[2], 0), columnDrop(columns[0], 0) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[0], 0), columnDrop(columns[1], 0) ]).determinant()],
                1/determinant()
            ),
            columnTimes(
                [Matrix2x2([ columnDrop(columns[2], 1), columnDrop(columns[1], 1) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[0], 1), columnDrop(columns[2], 1) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[1], 1), columnDrop(columns[0], 1) ]).determinant()],
                1/determinant()
            ),
            columnTimes(
                [Matrix2x2([ columnDrop(columns[1], 2), columnDrop(columns[2], 2) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[2], 2), columnDrop(columns[0], 2) ]).determinant(),
                 Matrix2x2([ columnDrop(columns[0], 2), columnDrop(columns[1], 2) ]).determinant()],
                1/determinant()
            )
        ])
    }
}
