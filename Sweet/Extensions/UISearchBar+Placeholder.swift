//
//  UISearchBar+Placeholder.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UISearchBar {
    func setPlaceholderLeft(placeholder: String) {
        self.placeholder = placeholder
        let centerSelector = NSSelectorFromString("setCenterPlaceholder:")
        if responds(to: centerSelector) {
//            let centeredPlaceholder = false
//            let signature = UISearchBar.self.instanceMethod(for: centerSelector)
        }
    }
    
    func setCancelText(text: String, textColor: UIColor) {
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self]).title = "返回"
        UIBarButtonItem.appearance(whenContainedInInstancesOf: [UISearchBar.self])
            .setTitleTextAttributes([NSAttributedStringKey.foregroundColor: UIColor.black,
                                     NSAttributedStringKey.font: UIFont.systemFont(ofSize: 18)],
                                    for: .normal)
        
    }
    
    func setTextFieldBackgroudColor(color: UIColor, cornerRadius: CGFloat) {
        let textField = self.value(forKey: "searchField")
        if let textField = textField {
            if let textField = textField as? UITextField {
                textField.backgroundColor = color
                textField.layer.cornerRadius = cornerRadius
                textField.layer.masksToBounds = true
            }
        }
    }
}
