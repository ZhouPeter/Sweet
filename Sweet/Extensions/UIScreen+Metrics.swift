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
    
    class func isIphoneX() -> Bool {
        if mainHeight() == 812 {
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
        let top: CGFloat = isIphoneX() ? 24 : 0
        return 64 + top
    }
    
    
    class func safeTopMargin() -> CGFloat {
        let top: CGFloat = isIphoneX() ? 44 : 0
        return top
    }
    
    class func safeBottomMargin() -> CGFloat {
        let bottom: CGFloat = isIphoneX() ? 34 : 0
        return 0 + bottom
    }
}
