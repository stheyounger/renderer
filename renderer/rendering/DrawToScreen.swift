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
    
    enum DisplayMode {
        case Wireframe
        case Surface
    }
    
    func draw(rendering: [Surface2d], camera: Camera, frameSize: CGSize, context: GraphicsContext, displayMode: DisplayMode) {
        let reorientedCoordinates: [Surface2d] = rendering.map { surface in
            let color = surface.color
            
            let adjustedPolygons = surface.polygons.map { polygon in
                Polygon<RenderedPoint>(orderedVertices: polygon.orderedVertices.map { point in
                    RenderedPoint(
                        point: reorientCoordinates(point.point, frameSize: frameSize, camera: camera),
                        depth: point.depth
                    )
                })
            }
            
            return Surface2d(polygons: adjustedPolygons, color: color)
        }
        
        
    
        switch (displayMode) {
        case .Wireframe:
            
            struct Surface2dLine <Point> {
                let color: Color
                let line: Line<Point>
                
                init(color: Color, line: Line<Point>) {
                    self.color = color
                    self.line = line
                }
            }
            
            let allLines = reorientedCoordinates.flatMap { surface in
                surface.polygons.flatMap { polygon in
                    polygon.orderedVertices.enumerated().map { i, vertex in
                        
                        let nextVertexIndex: Int;
                        if (i+1 < polygon.orderedVertices.count) {
                            nextVertexIndex = i + 1
                        } else {
                            nextVertexIndex = 0
                        }
                        let nextVertex = polygon.orderedVertices[nextVertexIndex]
                        
                        return Surface2dLine(color: surface.color, line: Line(start: vertex, end: nextVertex))
                    }
                }
            }
            
            let linesSortedByDepth = allLines.sorted(by: { a, b in
                
                let aDepth = a.line.start.depth + a.line.end.depth
                let bDepth = b.line.start.depth + b.line.end.depth
                
                let aGoesBeforeB = aDepth > bDepth
                return aGoesBeforeB
            })
            
            
            linesSortedByDepth.forEach { surfaceLine in
                let line = Line(start: surfaceLine.line.start.point, end: surfaceLine.line.end.point)
                let depth = surfaceLine.line.start.depth + surfaceLine.line.end.depth
                context.stroke(lineToCGPath(line), with: .color(surfaceLine.color), lineWidth: depth)
            }
            
        case .Surface:
            reorientedCoordinates.forEach { surface in
                surface.polygons.forEach { polygon in
                    let pointPolygon = Polygon(orderedVertices: polygon.orderedVertices.map { pointPlus in
                        pointPlus.point
                    })
                    context.fill(polygonToCGPath(pointPolygon.reorderVertices()), with: .color(surface.color))
                }
            }
        }
    }
}
