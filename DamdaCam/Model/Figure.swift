//
//  Figure.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/01/30.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

final class Figure: NSObject {
    
    enum Shape {
        case rectangle
        case rounded
        case circle
        case triangle
        case heart
        
        var path: UIBezierPath {
            switch self {
            case .rectangle:
                return UIBezierPath(rect: self.originalRect)
                
            case .rounded:
                return UIBezierPath(roundedRect: self.originalRect, cornerRadius: 10.0)
                
            case .circle:
                return UIBezierPath(arcCenter: CGPoint(x: self.originalRect.midX, y: self.originalRect.midY), radius: self.originalRect.width / 2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
                
            case .triangle:
                return self.drawTrianglePath()
                
            case .heart:
                return self.drawHeartPath()
            }
        }
        
        private var originalRect: CGRect {
            CGRect(x: 90.5, y: 23, width: 71.0, height: 71.0)
        }
        
        private func drawTrianglePath() -> UIBezierPath {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: originalRect.minX, y: originalRect.maxY))
            path.addLine(to: CGPoint(x: originalRect.maxX, y: originalRect.maxY))
            path.addLine(to: CGPoint(x: originalRect.midX, y: originalRect.minY))
            path.close()
            
            return path
        }
        
        private func drawHeartPath() -> UIBezierPath {
            let path = UIBezierPath()
            let scale: Double = 1.0
            
            let scaledWidth = (originalRect.size.width * CGFloat(scale))
            let scaledXValue = originalRect.minX
            let scaledHeight = (originalRect.size.height * CGFloat(scale))
            let scaledYValue = originalRect.minY
            
            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
            
            path.move(to: CGPoint(x: originalRect.midX, y: scaledRect.origin.y + scaledRect.size.height))
            
            
            path.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                          controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3/4),y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addCurve(to: CGPoint(x: originalRect.midX, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
            
            path.close()
            
            return path
        }
        
        var description: String {
            return String(describing: self)
        }
    }
    
    var shape: Shape = .rectangle
    var width: CGFloat = 2.0
    var depth: CGFloat = 2.0
    var color: UIColor = .white
    var fillState: Bool = false
    
}
