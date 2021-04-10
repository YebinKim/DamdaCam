//
//  UINavigationController+Extension.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2021/04/11.
//  Copyright © 2021 김예빈. All rights reserved.
//

import UIKit

extension UINavigationController {

    func pushFromStoryboard(_ name: String) {
        let storyboard: UIStoryboard = UIStoryboard(name: name, bundle: nil)
        if let nextVC = storyboard.instantiateInitialViewController() {
            self.pushViewController(nextVC, animated: true)
        }
    }
}
