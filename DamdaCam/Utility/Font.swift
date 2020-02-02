//
//  Font.swift
//  DamdaCam
//
//  Created by Yebin Kim on 2020/02/02.
//  Copyright © 2020 김예빈. All rights reserved.
//

import UIKit

final class Font {
    
    func thin(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Thin", size: size)
    }
    
    func light(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Light", size: size)
    }
    
    func demiLight(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-DemiLight", size: size)
    }
    
    func regular(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Regular", size: size)
    }
    
    func medium(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Medium", size: size)
    }
    
    func bold(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Bold", size: size)
    }
    
    func black(_ size: CGFloat) -> UIFont? {
        UIFont(name: "NotoSansCJKkr-Black", size: size)
    }
    
}
