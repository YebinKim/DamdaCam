//
//  PhotoAlbumItemCollectionViewCell.swift
//  DamdaCam
//
//  Created by 김예빈 on 2019. 4. 14..
//  Copyright © 2019년 김예빈. All rights reserved.
//

import UIKit

final class GalleryCollectionViewCell: UICollectionViewCell {

    static var identifier: String {
        return String(describing: self)
    }
    
    @IBOutlet weak var galleryImageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        if isSelected {
            self.galleryImageView.layer.borderColor = UIColor(named: "lightGray")?.cgColor
            self.galleryImageView.layer.borderWidth = 3
        } else {
            self.galleryImageView.layer.borderColor = UIColor.clear.cgColor
            self.galleryImageView.layer.borderWidth = 0
        }
    }
    
//    override var isSelected: Bool {
//        didSet {
//            
//            if isSelected {
//                self.photoImageView.layer.borderColor = (UIColor(red: 238/255, green: 238/255, blue: 238/255, alpha: 1) as! CGColor)
//                self.photoImageView.layer.borderWidth = 3
//            } else {
//                self.photoImageView.layer.borderColor = UIColor.clear.cgColor
//                self.photoImageView.layer.borderWidth = 0
//            }
//        }
//    }
    
}
