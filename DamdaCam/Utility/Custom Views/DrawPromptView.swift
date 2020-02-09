//
//  DrawPromptView.swift
//  DamdaCam
//
//  Created by 김예빈 on 2018. 12. 8..
//  Copyright © 2018년 김예빈. All rights reserved.
//
// AR Drawing

import UIKit

class DrawPromptView: UIView {

    let circleWidth: CGFloat = 25
    let circleHeight: CGFloat = 25

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()

        let circlePath = UIBezierPath(ovalIn: CGRect(x: 0, y: 0, width: circleWidth, height: circleHeight))
        let circle = CAShapeLayer()
        circle.path = circlePath.cgPath
        circle.fillColor = UIColor(white: 1.0, alpha: 0.75).cgColor

        let circleX = (self.frame.size.width - circleWidth)/2
        let circleY = (self.frame.size.height - circleHeight)/2
        circle.frame = CGRect(x: circleX, y: circleY, width: self.frame.size.width, height: self.frame.size.height)
        self.layer.addSublayer(circle)

        growAnimation()
    }

    private func growAnimation() {
        UIView.animate(withDuration: 0.6, delay: 0.2, options: [.curveEaseInOut], animations: {
            self.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }, completion: { _ in
            UIView.animate(withDuration: 0.6, delay: 0.25, options: [.curveEaseInOut], animations: {
                self.transform = .identity
            }, completion: { _ in
                self.growAnimation()
             })
        })
    }
}
