//
//  Camera.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

struct Camera {
    let frameCenter: Point3d
    
    let direction: Vector3d
    let verticalDirection: Vector3d
    let horizontalDirection: Vector3d
    
    let focalPoint: Point3d
    
    let frameWidth: Double
    let frameHeight: Double
    
    
    
    init(
        frameCenter: Point3d,
        direction: Vector3d,
        focalLength: Double,
        frameWidth: Double,
        frameHeight: Double
    ) {
        self.frameCenter = frameCenter
        
        let normalizedDirection = direction.normalize()
        
        self.direction = normalizedDirection
        self.verticalDirection = Vector3d(Point3d(x: 0, y: 1, z: 0))
        self.horizontalDirection = normalizedDirection.cross(verticalDirection).normalize()
        print("direction: \(direction)")
        print("verticalDirection: \(verticalDirection)")
        print("horizontalDirection: \(horizontalDirection)")
        
        let vectorToFocalPoint = Vector3d(frameCenter).plus(normalizedDirection.times(-focalLength))
        self.focalPoint = Point3d(
            x: vectorToFocalPoint.dimensions[0],
            y: vectorToFocalPoint.dimensions[1],
            z: vectorToFocalPoint.dimensions[2]
        )
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }
    
    
}
