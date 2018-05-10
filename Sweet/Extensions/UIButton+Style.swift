//
//  UIButton+Style.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum ContactButtonStyle {
    case none
    case noBorderGray
    case borderBlue
    case borderGray
    case backgroundColorGray
    case backgroundColorBlue
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
        case .borderGray:
            setTitleColor(UIColor(hex: 0x9B9B9B), for: .normal)
            backgroundColor = .white
            layer.borderColor = UIColor(hex: 0x9B9B9B).cgColor
            layer.borderWidth = 1
        case .backgroundColorGray:
            setTitleColor(.white, for: .normal)
            backgroundColor = UIColor(hex: 0x9B9B9B)
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        case .backgroundColorBlue:
            setTitleColor(.white, for: .normal)
            backgroundColor = UIColor.xpBlue()
            layer.borderColor = UIColor.clear.cgColor
            layer.borderWidth = 0
        default:
            break
        }
        
    }
}
