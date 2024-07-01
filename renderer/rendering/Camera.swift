//
//  Camera.swift
//  renderer
//
//  Created by James Penrose on 6/10/24.
//

import Foundation

struct Orientation3d {
    let xDirection: Vector3d
    let yDirection: Vector3d
    let zDirection: Vector3d
    
    init(xDirection: Vector3d, yDirection: Vector3d, zDirection: Vector3d) {
        self.xDirection = xDirection.normalize()
        self.yDirection = yDirection.normalize()
        self.zDirection = zDirection.normalize()
    }
}

struct Camera {
    let frameCenter: Point3d
    
    let direction: Vector3d
    let verticalDirection: Vector3d
    let horizontalDirection: Vector3d
    let orientation: Orientation3d
    
    let focalPoint: Point3d
    let fovRadians: Double
    
    let frameWidth: Double
    let frameHeight: Double
    
    init(
        frameCenter: Point3d,
        orientation: Orientation3d,
        fovRadians: Double,
        frameWidth: Double,
        frameHeight: Double
    ) {
        self.fovRadians = fovRadians
        let focalLength = cos(fovRadians/2) * frameWidth
    
        self.frameCenter = frameCenter
        
        self.orientation = orientation
        self.direction = orientation.zDirection
        self.verticalDirection = orientation.yDirection
        self.horizontalDirection = orientation.xDirection
        
        self.focalPoint = Camera.createFocalPointFromFocalLength(
            focalLength: focalLength,
            frameCenter: frameCenter,
            normalizedDirection: orientation.zDirection
        )
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }
    
//    init(
//        frameCenter: Point3d,
//        
//        orientation: Orientation3d,
//        
//        focalLength: Double,
//        
//        frameWidth: Double,
//        frameHeight: Double
//    ) {
//        self.frameCenter = frameCenter
//        
//        self.orientation = orientation
//        self.direction = orientation.zDirection
//        self.verticalDirection = orientation.yDirection
//        self.horizontalDirection = orientation.xDirection
//        
//        self.focalPoint = Camera.createFocalPointFromFocalLength(
//            focalLength: focalLength,
//            frameCenter: frameCenter,
//            normalizedDirection: orientation.zDirection
//        )
//        
//        self.frameWidth = frameWidth
//        self.frameHeight = frameHeight
//    }
    
    init(
        frameCenter: Point3d,
        direction: Vector3d,
        fovRadians: Double,
        frameWidth: Double,
        frameHeight: Double
    ) {
        self.frameCenter = frameCenter
        
        let normalizedDirection = direction.normalize()
        
        self.direction = normalizedDirection
    
        self.orientation = Camera.createOrientationFromZDirection(
            zDirection: normalizedDirection,
            previousOrientation: Orientation3d(
                xDirection: Vector3d(Point3d(x: 1, y: 0, z: 0)),
                yDirection: Vector3d(Point3d(x: 0, y: 1, z: 0)),
                zDirection: Vector3d(Point3d(x: 0, y: 0, z: 1)))
        )
        
        self.horizontalDirection = orientation.xDirection
        self.verticalDirection = orientation.yDirection
        
        print("direction: \(direction)")
        print("horizontalDirection: \(horizontalDirection)")
        print("verticalDirection: \(verticalDirection)")
        
        
        self.fovRadians = fovRadians
        let focalLength = cos(fovRadians/2) * frameWidth
        self.focalPoint = Camera.createFocalPointFromFocalLength(
            focalLength: focalLength,
            frameCenter: frameCenter,
            normalizedDirection: normalizedDirection
        )
        
        self.frameWidth = frameWidth
        self.frameHeight = frameHeight
    }
    
    static func createFocalPointFromFocalLength(focalLength: Double, frameCenter: Point3d, normalizedDirection: Vector3d) -> Point3d {
        let vectorToFocalPoint = Vector3d(frameCenter).plus(normalizedDirection.times(-focalLength))
        return Point3d(
            x: vectorToFocalPoint.dimensions[0],
            y: vectorToFocalPoint.dimensions[1],
            z: vectorToFocalPoint.dimensions[2]
        )
    }
    
    static func createOrientationFromZDirection(zDirection: Vector3d, previousOrientation: Orientation3d) -> Orientation3d {
    
        let intermediate = zDirection.times(-1).plus(Vector3d(Point3d(x: 0, y: 0.0000001, z: 0)))
            
        let xDirection = intermediate.cross(zDirection).normalize()
        
        let yDirection = zDirection.cross(xDirection).normalize()
        
        return Orientation3d(xDirection: xDirection, yDirection: yDirection, zDirection: zDirection)
    }
    
    func changeAngle(horizontalAngleChangeRadians: Double, verticalAngleChangeRadians: Double) -> Camera {
    
//        let newZ = Vector3d(Point3d(
//            x: 0,
//            y: sin(verticalAngleChangeRadians),
//            z: cos(verticalAngleChangeRadians)
//        )).normalize()
//    
//        let newZ = Vector3d(Point3d(
//            x: sin(horizontalAngleChangeRadians),
//            y: 0,
//            z: cos(horizontalAngleChangeRadians)
//        )).normalize()
        
        let newZ = Vector3d(Point3d(
            x: sin(horizontalAngleChangeRadians),
            y: sin(verticalAngleChangeRadians),
            z: cos(horizontalAngleChangeRadians) * cos(verticalAngleChangeRadians)
        )).normalize()
    
        let newBasisOrientation = Camera.createOrientationFromZDirection(zDirection: newZ, previousOrientation: orientation)
        
        let newBasis = Matrix3x3([
            newBasisOrientation.xDirection.dimensions,
            newBasisOrientation.yDirection.dimensions,
            newBasisOrientation.zDirection.dimensions
        ])

        let forward = orientation.zDirection.translated(matrixColumns: newBasis.columns)
        let horizontal = orientation.xDirection.translated(matrixColumns: newBasis.columns)//Camera.createOrientationFromZDirection(zDirection: forward, previousOrientation: orientation).xDirection
        let vertical = orientation.yDirection.translated(matrixColumns: newBasis.columns)
        
        return Camera(
            frameCenter: frameCenter,
//            orientation: Camera.createOrientationFromZDirection(zDirection: forward, previousOrientation: orientation),
            orientation: Orientation3d(xDirection: horizontal, yDirection: vertical, zDirection: forward),
            fovRadians: fovRadians,
            frameWidth: frameWidth,
            frameHeight: frameHeight
        )
    }
    
    func changeFrameCenter(frameCenterChange: Point3d) -> Camera {
        
        return Camera (
            frameCenter: frameCenter.plus(frameCenterChange),
            direction: orientation.zDirection,
            fovRadians: fovRadians,
            frameWidth: frameWidth,
            frameHeight: frameHeight
        )
        
//        return Camera(
//            frameCenter: ,
//            orientation: orientation,
//            focalPoint: focalPoint,
//            frameWidth: frameWidth,
//            frameHeight: frameHeight
//        )
    }
}
