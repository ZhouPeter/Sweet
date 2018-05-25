//
//  UIView+Shadow.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIView {
    func enableShadow() {
        layer.shadowRadius = 4
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.4
        layer.shadowOffset = CGSize(width: 2, height: 2)
    }
}

