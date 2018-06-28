//
//  MakeColorsLayer.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension UINavigationBar {
    func setBackgroundGradientImage(colors: [UIColor]) {
        let image = UINavigationBar.gradientImage(
                    bounds: CGRect(x: 0, y: 0, width: UIScreen.mainWidth(), height: UIScreen.navBarHeight()),
                    colors: colors)
        setBackgroundImage(image, for: .default)
    }
    
    class func gradientImage(bounds: CGRect, colors: [UIColor]) -> UIImage {
        var array = [AnyHashable]()
        for color in colors {
            array.append(color.cgColor)
        }
        UIGraphicsBeginImageContextWithOptions(bounds.size, true, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        context?.saveGState()
        let colorSpace = colors.last?.cgColor.colorSpace
        let gradient = CGGradient(colorsSpace: colorSpace, colors: array as CFArray, locations: nil)
        let start = CGPoint(x: 0.0, y: 0.0)
        let  end = CGPoint(x: bounds.size.width, y: bounds.size.height)
        context?.drawLinearGradient(gradient!, start: start, end: end,
                                    options: [.drawsBeforeStartLocation, .drawsAfterEndLocation])
        let image: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
        context?.restoreGState()
        UIGraphicsEndImageContext()
        return image!
    }
}
