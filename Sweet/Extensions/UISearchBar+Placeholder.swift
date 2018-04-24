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
}
