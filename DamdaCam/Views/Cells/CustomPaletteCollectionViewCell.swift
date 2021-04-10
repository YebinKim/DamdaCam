//
//  CustomPaletteCollectionViewCell.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 5. 13..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

final class CustomPaletteCollectionViewCell: UICollectionViewCell {

    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet var customColor: UIView!
    
    override var isSelected: Bool {
        didSet {
            if self.isSelected {
                //                print(textLabel)
            } else {
                //This block will be executed whenever the cell’s selection state is set to false (i.e For the rest of the cells)
            }
        }
    }
}
