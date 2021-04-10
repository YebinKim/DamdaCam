//
//  CGColor+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import UIKit

extension CGColor {

    var red: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.red)
    }

    var green: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.green)
    }

    var blue: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.blue)
    }

    var alpha: Float {
        let ciColor = CIColor(cgColor: self)
        return Float(ciColor.alpha)
    }
}
