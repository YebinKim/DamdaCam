//
//  SCNNode+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import ARKit

extension SCNNode {
    func setHighlighted( _ highlighted: Bool = true, _ highlightedBitMask: Int = 2) {
        categoryBitMask = highlightedBitMask
        for child in self.childNodes {
            child.setHighlighted()
        }
    }
}
