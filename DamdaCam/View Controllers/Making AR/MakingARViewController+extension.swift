//
//  MakingARViewController+extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/19.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

extension MakingARViewController: UICollectionViewDataSource, UICollectionViewDelegate {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let CustomColor = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColor", for: indexPath) as? CustomPaletteCollectionViewCell else { return UICollectionViewCell() }
        
        CustomColor.customColor.layer.cornerRadius = 4
        
        if indexPath.row < customPaletteArray.count {
            CustomColor.customColor.backgroundColor = customPaletteArray[indexPath.row]
            CustomColor.customColor.layer.borderColor = UIColor.clear.cgColor
        } else {
            CustomColor.customColor.backgroundColor = UIColor.clear
            CustomColor.customColor.layer.borderWidth = 1
            CustomColor.customColor.layer.borderColor = Properties.shared.color.gray.cgColor
        }
        
        return CustomColor
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColor", for: indexPath) is CustomPaletteCollectionViewCell else { return }
        
        if indexPath.row < customPaletteArray.count {
            pickedColor = customPaletteArray[indexPath.row]
            colorPicker.selectedColor = pickedColor
            //            self.touchDelegate?.setStrokeColor(customPaletteArray[indexPath.row].cgColor)
        }
    }
    
}
