//
//  UIView+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import UIKit

extension UIView {

    @discardableResult
    func initFromNib<T: UIView>() -> T? {
        let nibName: String = String(describing: type(of: self))
        guard let contentView = Bundle(for: type(of: self)).loadNibNamed(nibName, owner: self, options: nil)?.first as? T else {
            return nil
        }
        contentView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addSubview(contentView)
        NSLayoutConstraint.activate([
            contentView.topAnchor.constraint(equalTo: self.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: self.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: self.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: self.trailingAnchor)
        ])
        return contentView
    }

    func dropShadow(
        opacity: Float = 0.15,
        radius: CGFloat = 1.0,
        offset: CGSize = CGSize.zero,
        color: CGColor = UIColor.black.cgColor
    ) {
        self.layer.shadowOpacity = opacity
        self.layer.shadowRadius = radius
        self.layer.shadowOffset = offset
        self.layer.shadowColor = color
    }

    func dropShadow(state: Bool) {
        if state {
            self.dropShadow(opacity: 0.3)
        } else {
            self.dropShadow(opacity: 0)
        }
    }

    func applyGradient_view(colors: [CGColor], state: Bool) {
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
