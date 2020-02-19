//
//  FigureDrawView.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/19.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

@IBDesignable
class FigureDrawView: UIView {
    var startPoint: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var endPoint: CGPoint? {
        didSet {
            self.setNeedsDisplay()
        }
    }
    
    var drawView: UIImageView!
    var shape: String!
    var fillState: Bool!
    var width: CGFloat!
    var color: UIColor!
    var touchEnded: Bool!
    
    // TODO: - 도형 제스쳐 추가
    /*
     func initGestureRecognizers() {
     let panGR = UIPanGestureRecognizer(target: self, action: #selector(didPan))
     addGestureRecognizer(panGR)
     
     let pinchGR = UIPinchGestureRecognizer(target: self, action: #selector(didPinch))
     addGestureRecognizer(pinchGR)
     
     let rotationGR = UIRotationGestureRecognizer(target: self, action: #selector(didRotate))
     addGestureRecognizer(rotationGR)
     }
     
     @objc func didPan(panGR: UIPanGestureRecognizer) {
     
     self.superview!.bringSubviewToFront(self)
     
     let translation = panGR.translation(in: self)
     
     self.center.x += translation.x
     self.center.y += translation.y
     
     panGR.setTranslation(CGPoint.zero, in: self)
     }
     
     @objc func didPinch(pinchGR: UIPinchGestureRecognizer) {
     
     self.superview!.bringSubviewToFront(self)
     
     let scale = pinchGR.scale
     
     self.transform = CGAffineTransform(scaleX: scale, y: scale)
     
     pinchGR.scale = 1.0
     }
     
     @objc func didRotate(rotationGR: UIRotationGestureRecognizer) {
     
     self.superview!.bringSubviewToFront(self)
     
     let rotation = rotationGR.rotation
     
     self.transform = CGAffineTransform(rotationAngle: rotation)
     
     rotationGR.rotation = 0.0
     }
     */
    
    override func draw(_ rect: CGRect) {
        if startPoint != nil && endPoint != nil {
            let layer = CAShapeLayer()
            
            let path = drawPath(rect: CGRect(x: min(startPoint!.x, endPoint!.x),
                                             y: min(startPoint!.y, endPoint!.y),
                                             width: abs(startPoint!.x - endPoint!.x),
                                             height: abs(startPoint!.y - endPoint!.y)),
                                shape: shape)
            
            UIColor.clear.setFill()
            path.stroke()
            path.lineWidth = 2.0
            
            if fillState {
                path.fill()
                color.setFill()
            } else {
                color.setStroke()
                path.lineWidth = width
            }
            
            if getTouchEnded() {
                if fillState {
                    layer.fillColor = color.cgColor
                    layer.strokeColor = UIColor.clear.cgColor
                    layer.lineWidth = 0.0
                } else {
                    layer.fillColor = UIColor.clear.cgColor
                    layer.strokeColor = color.cgColor
                    layer.lineWidth = width
                }
                
                layer.path = path.cgPath
                drawView.layer.addSublayer(layer)
            }
        }
    }
    
    func setDrawView(sendView: UIImageView) {
        drawView = sendView
    }
    
    func getDrawView() -> UIImageView {
        return drawView
    }
    
    func setShape(sendShape: String) {
        shape = sendShape
    }
    
    func getShape() -> String {
        return shape
    }
    
    func setFillState(sendState: Bool) {
        fillState = sendState
    }
    
    func getFillState() -> Bool {
        return fillState
    }
    
    func setWidth(sendWidth: CGFloat) {
        width = sendWidth
    }
    
    func getWidth() -> CGFloat {
        return width
    }
    
    func setColor(sendColor: UIColor) {
        color = sendColor
    }
    
    func getColor() -> UIColor {
        return color
    }
    
    func setTouchEnded(sendState: Bool) {
        touchEnded = sendState
    }
    
    func getTouchEnded() -> Bool {
        return touchEnded
    }
    
    func drawPath(rect: CGRect, shape: String) -> UIBezierPath {
        if shape == "Rectangle" {
            let path = UIBezierPath(rect: rect)
            
            return path
        }
        
        if shape == "Rounded" {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: 10.0)
            
            return path
        }
        
        if shape == "Circle" {
            let path = UIBezierPath(arcCenter: CGPoint(x: rect.midX, y: rect.midY), radius: rect.width / 2, startAngle: CGFloat(0), endAngle: CGFloat(Double.pi * 2.0), clockwise: true)
            
            return path
        }
        
        if shape == "Triangle" {
            let path = UIBezierPath()
            path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
            path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
            path.close()
            
            return path
        }
        
        if shape == "Heart" {
            let path = UIBezierPath()
            let scale: Double = 1.0
            
            let scaledWidth = (rect.size.width * CGFloat(scale))
            let scaledXValue = rect.minX
            let scaledHeight = (rect.size.height * CGFloat(scale))
            let scaledYValue = rect.minY
            
            let scaledRect = CGRect(x: scaledXValue, y: scaledYValue, width: scaledWidth, height: scaledHeight)
            
            path.move(to: CGPoint(x: rect.midX, y: scaledRect.origin.y + scaledRect.size.height))
            
            path.addCurve(to: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/4)),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) ,
                          controlPoint2: CGPoint(x: scaledRect.origin.x, y: scaledRect.origin.y + (scaledRect.size.height/2)) )
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addArc(withCenter: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width * 3/4), y: scaledRect.origin.y + (scaledRect.size.height/4)),
                        radius: (scaledRect.size.width/4),
                        startAngle: CGFloat(Double.pi),
                        endAngle: 0,
                        clockwise: true)
            
            path.addCurve(to: CGPoint(x: rect.midX, y: scaledRect.origin.y + scaledRect.size.height),
                          controlPoint1: CGPoint(x: scaledRect.origin.x + scaledRect.size.width, y: scaledRect.origin.y + (scaledRect.size.height/2)),
                          controlPoint2: CGPoint(x: scaledRect.origin.x + (scaledRect.size.width/2), y: scaledRect.origin.y + (scaledRect.size.height*3/4)) )
            
            path.close()
            
            return path
        }
        
        return UIBezierPath()
    }
}
