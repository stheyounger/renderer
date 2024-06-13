//
//  Line.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation


struct Line<Point> {
    let start: Point
    let end: Point
    
    init (start: Point, end: Point) {
        self.start = start
        self.end = end
    }
}
