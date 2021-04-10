//
//  CGPoint+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import ARKit

extension CGPoint {

    init(_ size: CGSize) {
        self.init()
        self.x = size.width
        self.y = size.height
    }

    init(_ vector: SCNVector3) {
        self.init()
        self.x = CGFloat(vector.x)
        self.y = CGFloat(vector.y)
    }

    var cgSize: CGSize {
        return CGSize(width: x, height: y)
    }

    func distanceTo(_ point: CGPoint) -> CGFloat {
        return (self - point).length()
    }

    func length() -> CGFloat {
        return sqrt(self.x * self.x + self.y * self.y)
    }

    func midpoint(_ point: CGPoint) -> CGPoint {
        return (self + point) / 2
    }

    func absolutePoint(in rect: CGRect) -> CGPoint {
        return CGPoint(x: x * rect.size.width, y: y * rect.size.height) + rect.origin
    }

    static func + (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x + right.x, y: left.y + right.y)
    }

    static func - (left: CGPoint, right: CGPoint) -> CGPoint {
        return CGPoint(x: left.x - right.x, y: left.y - right.y)
    }

    static func += (left: inout CGPoint, right: CGPoint) {
        left = left + right
    }

    static func -= (left: inout CGPoint, right: CGPoint) {
        left = left - right
    }

    static func / (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x / right, y: left.y / right)
    }

    static func * (left: CGPoint, right: CGFloat) -> CGPoint {
        return CGPoint(x: left.x * right, y: left.y * right)
    }

    static func /= (left: inout CGPoint, right: CGFloat) {
        left = left / right
    }

    static func *= (left: inout CGPoint, right: CGFloat) {
        left = left * right
    }
}
