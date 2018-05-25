//
//  UIView+Screenshot.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension UIView {
    func screenshot(afterScreenUpdates: Bool = false) -> UIImage? {
        UIGraphicsBeginImageContextWithOptions(UIScreen.main.bounds.size, false, UIScreen.main.scale)
        drawHierarchy(in: UIScreen.main.bounds, afterScreenUpdates: afterScreenUpdates)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
