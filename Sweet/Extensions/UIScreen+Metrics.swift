//
//  UIScreen+Metrics.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIScreen {
    class func mainWidth() -> CGFloat {
        return UIScreen.main.bounds.size.width
    }
    
    class func mainHeight() -> CGFloat {
        return UIScreen.main.bounds.size.height
    }
    
    class func isNotched() -> Bool {
        let nativeHeight = UIScreen.main.nativeBounds.height
        if nativeHeight == 2436 || nativeHeight == 1792 || nativeHeight == 2688  {
            return true
        } else {
            return false
        }
    }
    
    class func is4InchOrLess() -> Bool {
        return mainHeight() <= 568
    }
    
    class func onePixel() -> CGFloat {
        return 1 / UIScreen.main.scale
    }
    
    class func navBarHeight() -> CGFloat {
        let top: CGFloat = isNotched() ? 24 : 0
        return 64 + top
    }
    
    class func safeTopMargin() -> CGFloat {
        let top: CGFloat = isNotched() ? 44 : 0
        return top
    }
    
    class func safeBottomMargin() -> CGFloat {
        let bottom: CGFloat = isNotched() ? 34 : 0
        return 0 + bottom
    }
}
