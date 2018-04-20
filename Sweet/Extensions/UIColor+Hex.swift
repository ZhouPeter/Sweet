//
//  UIColor+Hex.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIColor {
    convenience init(hex: UInt) {
        var red, green, blue, alpha: CGFloat
        red = CGFloat((hex >> 16) & 0xFF) / CGFloat(0xFF)
        green = CGFloat((hex >> 8) & 0xFF) / CGFloat(0xFF)
        blue = CGFloat((hex >> 0) & 0xFF) / CGFloat(0xFF)
        alpha = hex > 0xFFFFFF ? CGFloat((hex >> 24) & 0xFF) / CGFloat(0xFF) : 1
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    convenience init(css: String) {
        if css.count == 0 {
            self.init(red: 0, green: 0, blue: 0, alpha: 1)
            return
        }
        var cString: String = css.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines).uppercased()
        if css.hasPrefix("#") {
            cString = cString.replacingOccurrences(of: "#", with: "0x")
        } else {
            cString = "0x" + cString
        }
        
        self.init(hex: UInt(cString)!)
        
    }
}
