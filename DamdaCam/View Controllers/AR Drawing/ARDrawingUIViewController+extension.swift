//
//  ARDrawingUIViewController+extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/16.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit


extension ARDrawingUIViewController: UITextViewDelegate {
    
}

extension ARDrawingUIViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 2
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if component == 0 {
            return 10
        } else {
            return 60
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView {
        let title = UILabel()
        title.font = Properties.shared.font.regular(15.0)
        title.textColor = UIColor(red: 84.0/255.0, green: 84.0/255.0, blue: 84.0/255.0, alpha: 1.0)
        title.text = String(row)
        title.textAlignment = .center
        
        if component == 0 {
            return title
        } else {
            return title
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        clipTime = (Double(plusClipPicker.selectedRow(inComponent: 0)) * 60.0) + Double(plusClipPicker.selectedRow(inComponent: 1))
    }
    
}

extension ARDrawingUIViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 18
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let CustomColor = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomColor", for: indexPath) as? CustomPaletteCollectionViewCell else { return UICollectionViewCell() }
        
        CustomColor.customColor.layer.cornerRadius = 4
        
        // FIXME
        self.customPaletteArray = DamdaData.shared.customPaletteArray
        
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
            drawingPenButton.backgroundColor = pickedColor
            self.touchDelegate?.setStrokeColor(pickedColor.cgColor)
        }
    }
    
}
