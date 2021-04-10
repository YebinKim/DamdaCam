//
//  UIButton+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import UIKit

extension UIButton {

    func applyGradient(colors: [CGColor?], state: Bool) {
        if state {
            self.layer.sublayers?[0].removeFromSuperlayer()

            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors as [Any]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = 20
            self.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors as [Any]
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = self.bounds
            gradientLayer.cornerRadius = 20
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }

    func applyGradient_rect(colors: [CGColor], state: Bool) {
        if state {
            self.layer.sublayers?[0].removeFromSuperlayer()

            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = self.bounds
            self.layer.insertSublayer(gradientLayer, at: 0)
        } else {
            let gradientLayer = CAGradientLayer()
            gradientLayer.colors = colors
            gradientLayer.startPoint = CGPoint(x: 0, y: 0)
            gradientLayer.endPoint = CGPoint(x: 1, y: 1)
            gradientLayer.frame = self.bounds
            self.layer.insertSublayer(gradientLayer, at: 0)
        }
    }
}
