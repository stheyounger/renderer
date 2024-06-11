//
//  Camera.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

struct Camera {
    let frameCenter: Point3d
    let focalPoint: Point3d
    let direction: Vector3d
    let frameWidth: Double
    let frameHeight: Double
    
    init(
        frameCenter: Point3d,
        direction: Vector3d,
        focalLength: Double,
        frameWidth: Double,
        frameHeight: Double
    ) {
        let normalizedDirection = direction.normalize()
        self.frameCenter = frameCenter
        let vectorToFocalPoint = Vector3d(frameCenter).plus(normalizedDirection.times(-focalLength))
        self.focalPoint = Point3d(
            x: vectorToFocalPoint.dimensions[0],
            y: vectorToFocalPoint.dimensions[1],
            z: vectorToFocalPoint.dimensions[2]
        )
        self.direction = normalizedDirection
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }
}
