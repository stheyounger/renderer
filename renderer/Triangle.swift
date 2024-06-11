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
}
