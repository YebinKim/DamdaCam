//
//  FilterCollectionViewCell.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 15..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

class FilterCollectionViewCell: UICollectionViewCell {
    @IBOutlet var filterPreviewImage: UIImageView!
    @IBOutlet var filterNameLabel: UILabel!
    
    override var isSelected: Bool{
        didSet{
            if self.isSelected
            {
                //                print(textLabel)
            }
            else
            {
                //This block will be executed whenever the cell’s selection state is set to false (i.e For the rest of the cells)
            }
        }
    }
}
