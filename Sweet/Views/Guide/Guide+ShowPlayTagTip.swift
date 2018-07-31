//
//  Guide+ShowPlayTagTip.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension Guide {
    class func showPlayTagTip(with path: CGPath) {
        let guide = Guide()
        let view = guide.rootView
        let focusView = FocusTagView(focusPath: path)
        view.addSubview(focusView)
        focusView.fill(in: view)
        let tip = Guide.makeTapGestureTip("点击小故事标签进入拍摄")
        let tipWidth: CGFloat = 50
        let tipheight: CGFloat = 50
        view.addSubview(tip)
        tip.constrain(width: tipWidth, height: tipheight)
        tip.center(to: view)
    }
}

