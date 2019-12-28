//
// TooltipView.swift
// Customizable Tooltips
//
// Copyright © 2017 Simon Wuyts
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.

import UIKit

@IBDesignable
class TooltipView: UIView {
    
    //MARK: - IBInspectable
    
    @IBInspectable var arrowTopLeft: Bool = false
    @IBInspectable var arrowTopCenter: Bool = true
    @IBInspectable var arrowTopRight: Bool = false
    @IBInspectable var arrowBottomLeft: Bool = false
    @IBInspectable var arrowBottomCenter: Bool = false
    @IBInspectable var arrowBottomRight: Bool = false
    
    @IBInspectable var fillColor: UIColor = UIColor(red: 43/255, green: 43/255, blue: 43/255, alpha: 0.28)
    
    @IBInspectable var borderColor: UIColor = UIColor(red:0, green:0, blue:0, alpha:0.05)
    @IBInspectable var borderRadius: CGFloat = 5
    @IBInspectable var borderWidth: CGFloat = 0
    
    @IBInspectable var shadowColor: UIColor = UIColor(red:0, green:0, blue:0, alpha:0)
    @IBInspectable var shadowOffsetX: CGFloat = 0
    @IBInspectable var shadowOffsetY: CGFloat = 2
    @IBInspectable var shadowBlur: CGFloat = 0
    
    //MARK: - Global Variables
    
    var tooltipWidth = 0
    var tooltipHeight = 0
    
    //MARK: - Initialization
    
    override func draw(_ rect: CGRect) {
        drawTooltip()
    }
    
    //MARK: - Private Methods
    
    // Orientation methods
    
    private func topLeft(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: y)
    }
    
    private func topRight(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(tooltipWidth) - x, y: y)
    }
    
    private func bottomLeft(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: x, y: CGFloat(tooltipHeight) - y)
    }
    
    private func bottomRight(_ x: CGFloat, _ y: CGFloat) -> CGPoint {
        return CGPoint(x: CGFloat(tooltipWidth) - x, y: CGFloat(tooltipHeight) - y)
    }
    
    // Draw methods
    
    private func drawTooltip() {
        
        tooltipWidth = Int(bounds.width)
        tooltipHeight = Int(bounds.height)
        
        // Define Bubble Shape
        
        let bubblePath = UIBezierPath()
        
        // Top left corner
        
        bubblePath.move(to: topLeft(0, borderRadius))
        bubblePath.addCurve(to: topLeft(borderRadius, 0), controlPoint1: topLeft(0, borderRadius / 2), controlPoint2: topLeft(borderRadius / 2, 0))
        
        // Top right corner
        
        bubblePath.addLine(to: topRight(borderRadius, 0))
        bubblePath.addCurve(to: topRight(0, borderRadius), controlPoint1: topRight(borderRadius / 2, 0), controlPoint2: topRight(0, borderRadius / 2))
        
        // Bottom right corner
        
        bubblePath.addLine(to: bottomRight(0, borderRadius))
        bubblePath.addCurve(to: bottomRight(borderRadius, 0), controlPoint1: bottomRight(0, borderRadius / 2), controlPoint2: bottomRight(borderRadius / 2, 0))
        
        // Bottom left corner
        
        bubblePath.addLine(to: bottomLeft(borderRadius, 0))
        bubblePath.addCurve(to: bottomLeft(0, borderRadius), controlPoint1: bottomLeft(borderRadius / 2, 0), controlPoint2: bottomLeft(0, borderRadius / 2))
        bubblePath.close()
        
        // Arrow
        
        if(arrowTopLeft) {
            bubblePath.move(to: topLeft(3, 10))
            bubblePath.addLine(to: topLeft(3, -4))
            bubblePath.addLine(to: topLeft(16, 2))
            bubblePath.close()
        }
        
        if(arrowTopCenter) {
            bubblePath.move(to: topLeft(CGFloat((tooltipWidth / 2) - 5), 0))
            bubblePath.addLine(to: topLeft(CGFloat(tooltipWidth / 2), -8))
            bubblePath.addLine(to: topLeft(CGFloat(tooltipWidth / 2 + 5), 0))
            bubblePath.close()
        }
        
        if(arrowTopRight) {
            bubblePath.move(to: topRight(16, 2))
            bubblePath.addLine(to: topRight(3, -4))
            bubblePath.addLine(to: topRight(3, 10))
            bubblePath.close()
        }
        
        if(arrowBottomLeft) {
            bubblePath.move(to: bottomLeft(16, 2))
            bubblePath.addLine(to: bottomLeft(3, -4))
            bubblePath.addLine(to: bottomLeft(3, 10))
            bubblePath.close()
        }
        
        if(arrowBottomCenter) {
            bubblePath.move(to: bottomLeft(CGFloat((tooltipWidth / 2) - 5), 0))
            bubblePath.addLine(to: bottomLeft(CGFloat(tooltipWidth / 2), -8))
            bubblePath.addLine(to: bottomLeft(CGFloat(tooltipWidth / 2 + 5), 0))
            bubblePath.close()
        }
        
        if(arrowBottomRight) {
            bubblePath.move(to: bottomRight(3, 10))
            bubblePath.addLine(to: bottomRight(3, -4))
            bubblePath.addLine(to: bottomRight(16, 2))
            bubblePath.close()
        }
        
        // Shadow Layer
        
        let shadowShape = CAShapeLayer()
        shadowShape.path = bubblePath.cgPath
        shadowShape.fillColor = fillColor.cgColor
        shadowShape.shadowColor = shadowColor.cgColor
        shadowShape.shadowOffset = CGSize(width: CGFloat(shadowOffsetX), height: CGFloat(shadowOffsetY))
        shadowShape.shadowRadius = CGFloat(shadowBlur)
        shadowShape.shadowOpacity = 0.8
        
        // Border Layer
        
        let borderShape = CAShapeLayer()
        borderShape.path = bubblePath.cgPath
        borderShape.fillColor = fillColor.cgColor
        borderShape.strokeColor = borderColor.cgColor
        borderShape.lineWidth = CGFloat(borderWidth*2)
        
        // Fill Layer
        
        let fillShape = CAShapeLayer()
        fillShape.path = bubblePath.cgPath
        fillShape.fillColor = fillColor.cgColor
        
        // Add Sublayers
        
        self.layer.insertSublayer(shadowShape, at: 0)
        self.layer.insertSublayer(borderShape, at: 0)
        self.layer.insertSublayer(fillShape, at: 0)
        
    }
    
}
