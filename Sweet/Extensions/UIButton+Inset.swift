//
//  UIButton+Inset.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension UIButton {

    func setImageTop(space: CGFloat) {
        layoutIfNeeded()
        titleLabel?.invalidateIntrinsicContentSize()
        guard let titleSize = titleLabel?.intrinsicContentSize else { return }
        guard let imageSize = imageView?.frame.size else { return }
        let imageLeft: CGFloat = 0
        let imageRight: CGFloat = -titleSize.width
        let imageBottom: CGFloat = 0
        let imageTop: CGFloat = -titleSize.height - space
        let titleTop: CGFloat = 0
        let titleBottom: CGFloat = -imageSize.height - space
        let titleLeft: CGFloat = -imageSize.width
        let titleRight: CGFloat = 0
        titleEdgeInsets = UIEdgeInsets(top: titleTop, left: titleLeft, bottom: titleBottom, right: titleRight)
        imageEdgeInsets = UIEdgeInsets(top: imageTop, left: imageLeft, bottom: imageBottom, right: imageRight)
    }
    
    func setImageRight(space: CGFloat) {
        layoutIfNeeded()
        titleLabel?.invalidateIntrinsicContentSize()
        guard let titleSize = titleLabel?.intrinsicContentSize else { return }
        guard let imageSize = imageView?.frame.size else { return }
        let imageLeft: CGFloat = titleSize.width + space
        let imageRight: CGFloat = -titleSize.width - space
        let imageBottom: CGFloat = 0
        let imageTop: CGFloat = 0
        let titleTop: CGFloat = 0
        let titleBottom: CGFloat = 0
        let titleLeft: CGFloat = -imageSize.width - space
        let titleRight: CGFloat = imageSize.width + space
        titleEdgeInsets = UIEdgeInsets(top: titleTop, left: titleLeft, bottom: titleBottom, right: titleRight)
        imageEdgeInsets = UIEdgeInsets(top: imageTop, left: imageLeft, bottom: imageBottom, right: imageRight)
        contentEdgeInsets = UIEdgeInsets.zero
    }
}
