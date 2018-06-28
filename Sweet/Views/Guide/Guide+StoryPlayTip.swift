//
//  Guide+StoryPlayTip.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension Guide {
    class func showStoryPlayTip() {
        let guide = Guide()
        let view = guide.rootView
        let mask = UIView()
        mask.backgroundColor = .black
        mask.alpha = 0.6
        view.addSubview(mask)
        mask.fill(in: view)
        let dashLine = DashView()
        dashLine.backgroundColor = .clear
        view.addSubview(dashLine)
        dashLine.align(.top)
        dashLine.align(.bottom)
        dashLine.constrain(width: 3)
        let width = guide.rootView.bounds.width
        let dashInset = width / 3
        dashLine.align(.left, to: view, inset: dashInset)
        let leftTip = Guide.makeTapGestureTip("上一个小故事")
        let rightTip = Guide.makeTapGestureTip("下一个小故事")
        view.addSubview(leftTip)
        view.addSubview(rightTip)
        let tipWidth: CGFloat = 50
        leftTip.constrain(width: tipWidth, height: tipWidth)
        rightTip.equal(.size, to: leftTip)
        leftTip.align(.left, to: view, inset: dashInset * 0.5 - tipWidth * 0.5)
        leftTip.centerY(to: view)
        rightTip.align(.right, to: view, inset: (width - dashInset) * 0.5 - tipWidth * 0.5)
        rightTip.centerY(to: view)
    }
    
    private class func makeTapGestureTip(_ tip: String) -> UIImageView {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "TapGesture"))
        let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        label.text = tip
        imageView.addSubview(label)
        label.pin(.top, to: imageView, spacing: 20)
        label.centerX(to: imageView)
        return imageView
    }
}
