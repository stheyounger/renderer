//
//  cuboid.swift
//  renderer
//
//  Created by James Penrose on 7/1/24.
//

import Foundation
import SwiftUI

struct Cuboid {
    
    let center: Point3d
    let xLength: Double
    let yLength: Double
    let zLength: Double
    let color: Color
    let orderedVertices: [Point3d]

    init (color: Color, center: Point3d, xLength: Double, yLength: Double, zLength: Double) {
        self.color = color
        self.center = center
        self.xLength = xLength
        self.yLength = yLength
        self.zLength = zLength
        
        let halfXLength = xLength/2
        let halfYLength = yLength/2
        let halfZLength = zLength/2
        
        self.orderedVertices = [
            Point3d(x: center.x+halfXLength, y: center.y+halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x+halfXLength, y: center.y-halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y-halfYLength, z: center.z+halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y+halfYLength, z: center.z+halfZLength),
            
            Point3d(x: center.x+halfXLength, y: center.y+halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x+halfXLength, y: center.y-halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y-halfYLength, z: center.z-halfZLength),
            Point3d(x: center.x-halfXLength, y: center.y+halfYLength, z: center.z-halfZLength),
        ]
    }
    
    func mesh() -> [Surface3d] {
        let vertices = orderedVertices
        return [
            Surface3d(triangles: [
                //Front
                Triangle(vertices[0], vertices[1], vertices[3]),
                Triangle(vertices[2], vertices[1], vertices[3]),
            ], color: color),
            Surface3d(triangles: [
                //Back
                Triangle(vertices[4], vertices[5], vertices[7]),
                Triangle(vertices[6], vertices[5], vertices[7]),
            ], color: color),
            Surface3d(triangles: [
                //Side
                Triangle(vertices[0], vertices[4], vertices[5]),
                Triangle(vertices[0], vertices[1], vertices[5]),
            ], color: color),
            Surface3d(triangles: [
                //Other Side
                Triangle(vertices[2], vertices[3], vertices[7]),
                Triangle(vertices[2], vertices[6], vertices[7]),
            ], color: color),
            Surface3d(triangles: [
                //Top
                Triangle(vertices[0], vertices[3], vertices[4]),
                Triangle(vertices[7], vertices[3], vertices[4]),
            ], color: color),
            Surface3d(triangles: [
                //Bottom
                Triangle(vertices[1], vertices[5], vertices[2]),
                Triangle(vertices[6], vertices[5], vertices[2]),
            ], color: color),
        ]
    }
}
