//
//  FaceAR.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/04.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

struct FaceARMotion {
    
    enum Kind: CaseIterable {
        case heart
        case angel
        case rabbit
        case cat
        case mouse
        case peach
        case baaam
        case mushroom
        case doughnut
        case flower
        
        var position: SCNVector3 {
            switch self {
            case .heart:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .angel:
                return SCNVector3(x: 0, y: 0, z: -5)
            case .rabbit:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .cat:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .mouse:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .peach:
                return SCNVector3(x: 0, y: 4.35, z: -5)
            case .baaam:
                return SCNVector3(x: 0, y: 4, z: -5)
            case .mushroom:
                return SCNVector3(x: 0, y: 2.5, z: -5)
            case .doughnut:
                return SCNVector3(x: 0, y: -4, z: -5)
            case .flower:
                return SCNVector3(x: 0, y: 0, z: -5)
            }
        }
        
        var name: String {
            String(describing: self)
        }
    }
    
    var kind: Kind {
        didSet {
            self.position = kind.position
            self.name = kind.name
            
//            if let image = UIImage(named: "FaceAR_\(self.name)") {
//                self.thumbnailImage = image
//            }
        }
    }
    
    var position: SCNVector3?
    var name: String?
//    var thumbnailImage: UIImage?
    
}
