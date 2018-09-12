//
//  UIWindow+Shot.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension UIScreen {
    class func screenShot() -> Data? {
        var imageSize = CGSize.zero
        let orientation = UIApplication.shared.statusBarOrientation
        if orientation.isPortrait {
            imageSize = UIScreen.main.bounds.size
        } else {
            imageSize = CGSize(width: UIScreen.mainHeight(), height: UIScreen.mainWidth())
        }
        UIGraphicsBeginImageContextWithOptions(imageSize,false, 0)
        let context = UIGraphicsGetCurrentContext()
        for window in UIApplication.shared.windows {
            if String(describing: type(of: window)) == "VolumeBarWindow" { continue }
            context?.saveGState()
            context?.translateBy(x: window.center.x, y: window.center.y)
            context?.concatenate(window.transform)
            context?.translateBy(x: -window.bounds.size.width * window.layer.anchorPoint.x,
                                 y: -window.bounds.size.height * window.layer.anchorPoint.y)
            if orientation == .landscapeLeft {
                context?.rotate(by: .pi / 2)
                context?.translateBy(x: 0, y: -imageSize.width)
            } else if orientation == .landscapeRight {
                context?.rotate(by: -(.pi / 2))
                context?.translateBy(x: -imageSize.height, y: 0)
            } else if orientation == .portraitUpsideDown {
                context?.rotate(by: .pi)
                context?.translateBy(x: -imageSize.width, y: -imageSize.height)
            }
            if window.responds(to: #selector(window.drawHierarchy(in:afterScreenUpdates:))) {
                window.drawHierarchy(in: window.bounds, afterScreenUpdates: true)
            } else {
                window.layer.render(in: context!)
            }
        }
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return UIImagePNGRepresentation(image!)
    }
}
