//
//  BGAR.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/04.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

struct BGARMotion {
    
    enum Kind: CaseIterable {
        case snow
        case blossom
        case rain
        case fish
        case greenery
        case fruits
        case glow
        
        var name: String {
            String(describing: self)
        }
    }
    
    var kind: Kind {
        didSet {
            self.name = kind.name
        }
    }
    
    var name: String?
    
}
