//
//  DrawToScreen.swift
//  renderer
//
//  Created by James Penrose on 7/1/24.
//

import Foundation
import SwiftUI

struct DrawToScreen {
    func reorientCoordinates(_ point: Point2d, frameSize: CGSize, camera: Camera) -> Point2d {
        func centerPoint(_ point: Point2d) -> Point2d {
            let centerX = frameSize.width/2
            let centerY = frameSize.height/2
            
            let flippedY = -point.y
            
            return Point2d(
                x: point.x + centerX,
                y: flippedY + centerY
            )
        }
        
        let smallSideOfWindow = min(frameSize.width, frameSize.height)
        let smallSideOfCamera = min(camera.frameWidth, camera.frameHeight)
        
        let cameraToWindowConversion = smallSideOfWindow/smallSideOfCamera
        
        print("cameraToWindowConversion: \(cameraToWindowConversion)")
        func stretched(_ point: Point2d) -> Point2d {
            
            func handleInfinity(_ n: Double) -> Double {
                return if (n == Double.infinity || n == Double.nan || n == Double.signalingNaN) {
                    Double.greatestFiniteMagnitude
                } else {
                    n
                }
            }
            
            let stretched = Point2d(
                x: handleInfinity(point.x * cameraToWindowConversion),
                y: handleInfinity(point.y * cameraToWindowConversion)
            )
            
            print("preStretch: \(point) postStretch: \(stretched)")
            
            return stretched
        }
        
        return centerPoint(stretched(point))
    }
    
    private func lineToCGPath(_ line: Line<Point2d>) -> Path {
        let start = CGPoint(x: line.start.x, y: line.start.y)
        let end = CGPoint(x: line.end.x, y: line.end.y)
        
        let path = CGMutablePath()
        path.move(to: start)
        path.addLine(to: end)
        
        return Path(path)
    }
    private func triangleToCGPath(_ triangle: Triangle<Point2d>) -> Path {
        let cgPoints: [CGPoint] = triangle.orderedVertices.map { point in
            CGPoint(x: point.x, y: point.y)
        }
        
        let path = CGMutablePath()
        cgPoints.enumerated().forEach { i, point in
            if (i == 0) {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        
        return Path(path)
    }
    
    private func polygonToCGPath(_ polygon: Polygon<Point2d>) -> Path {
        let cgPoints: [CGPoint] = polygon.orderedVertices.map { point in
            CGPoint(x: point.x, y: point.y)
        }
        
        let path = CGMutablePath()
        cgPoints.enumerated().forEach { i, point in
            if (i == 0) {
                path.move(to: point)
            } else {
                path.addLine(to: point)
            }
        }
        
        return Path(path)
    }
    
    func draw(rendering: [Surface2d], camera: Camera, frameSize: CGSize, context: GraphicsContext) {
        let reorientedCoordinates: [Surface2d] = rendering.map { surface in
            let color = surface.color
            
            let adjustedPolygons = surface.polygons.map { polygon in
                Polygon<Point2d>(orderedVertices: polygon.orderedVertices.map { point in
                    reorientCoordinates(point, frameSize: frameSize, camera: camera)
                }).reorderVertices()
            }
            
            return Surface2d(polygons: adjustedPolygons, color: color)
        }
        
        reorientedCoordinates.forEach { surface in
            surface.polygons.forEach { polygon in
                let path = Polygon(orderedVertices: polygon.orderedVertices + [polygon.orderedVertices.first!])
//                context.stroke(polygonToCGPath(path), with: .color(surface.color))
                context.fill(polygonToCGPath(polygon), with: .color(surface.color))
            }
        }
    }
}