//
//  UIButton+Style.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


enum ContactButtonStyle {
    case noBorderGray
    case borderBlue
}

extension UIButton {
    func setButtonStyle(style: ContactButtonStyle) {
        switch style {
        case .noBorderGray:
            setTitleColor(UIColor.xpTextGray(), for: .normal)
            backgroundColor = .white
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        case .borderBlue:
            setTitleColor(UIColor.xpBlue(), for: .normal)
            backgroundColor = .white
            layer.borderColor = UIColor.xpBlue().cgColor
            layer.borderWidth = 1
        }
    }
}
