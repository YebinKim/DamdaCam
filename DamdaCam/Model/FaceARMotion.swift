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
        case Heart
        case Angel
        case Rabbit
        case Cat
        case Mouse
        case Peach
        case BAAAM
        case Mushroom
        case Doughnut
        case Flower
        
        var position: SCNVector3 {
            switch self {
            case .Heart:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .Angel:
                return SCNVector3(x: 0, y: 0, z: -5)
            case .Rabbit:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .Cat:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .Mouse:
                return SCNVector3(x: 0, y: 3.5, z: -5)
            case .Peach:
                return SCNVector3(x: 0, y: 4.35, z: -5)
            case .BAAAM:
                return SCNVector3(x: 0, y: 4, z: -5)
            case .Mushroom:
                return SCNVector3(x: 0, y: 2.5, z: -5)
            case .Doughnut:
                return SCNVector3(x: 0, y: -4, z: -5)
            case .Flower:
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
