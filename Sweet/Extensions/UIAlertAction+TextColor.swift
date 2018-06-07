//
//  UIAlertAction+TextColor.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension UIAlertAction {

    func setTextColor(color: UIColor) {
        var count: UInt32 = 0
        guard let ivars = class_copyIvarList(UIAlertAction.classForCoder(), &count) else { return }
        for index in 0..<Int(count) {
            let ivar = ivars[index]
            let name = ivar_getName(ivar)
            if let varName = String(utf8String: name!) {
                if varName == "_titleTextColor" {
                    setValue(color, forKey: "titleTextColor")
                }
            }
        }
    }
    
    class func makeAlertAction(textColor: UIColor = .black,
                               title: String?,
                               style: UIAlertActionStyle,
                               handler: ((UIAlertAction) -> Void)?) -> UIAlertAction {
        let action = UIAlertAction(title: title, style: style, handler: handler)
        action.setTextColor(color: textColor)
        return action
    }
}
