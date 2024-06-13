//
//  Surface3d.swift
//  renderer
//
//  Created by James Penrose on 6/12/24.
//

import Foundation
import SwiftUI

struct Surface3d {
    let triangles: [Triangle<Point3d>]
    let color: Color
    
    init(triangles: [Triangle<Point3d>], color: Color) {
        self.triangles = triangles
        self.color = color
    }
    
    func copyColor(triangles: [Triangle<Point3d>]) -> Surface3d {
        return Surface3d(triangles: triangles, color: color)
    }
    
    func rotateAroundY(rotationCenter: Point3d, angleRadians: Double) -> Surface3d {
        return copyColor(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundY(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
    func rotateAroundX(rotationCenter: Point3d, angleRadians: Double) -> Surface3d {
        return copyColor(triangles: triangles.map { triangle in
            Triangle(orderedVertices: triangle.orderedVertices.map { vertex in
                vertex.rotateAroundX(rotationCenter: rotationCenter, angleRadians: angleRadians)
            })
        })
    }
}
