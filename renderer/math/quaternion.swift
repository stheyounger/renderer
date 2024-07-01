//
//  quaternion.swift
//  renderer
//
//  Created by James Penrose on 7/1/24.
//

import Foundation

struct Quaternion {
    let w: Double
    let x: Double
    let y: Double
    let z: Double
    
    init(w: Double, x: Double, y: Double, z: Double) {
        self.w = w
        self.x = x
        self.y = y
        self.z = z
    }
}
