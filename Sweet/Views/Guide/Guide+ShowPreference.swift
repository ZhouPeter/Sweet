//
//  Guide+ShowPreference.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension Guide {
    class func showPreference() {
        let guide = Guide()
        let view = guide.rootView
        let mask = UIView()
        mask.backgroundColor = .black
        mask.alpha = 0.6
        view.addSubview(mask)
        mask.fill(in: view)
        let label = UILabel()
        label.text = "请选择你喜欢的选项"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)
        label.centerX(to: view)
        let baseTop = UIScreen.navBarHeight() + cardInsetTop + 140
        label.layoutIfNeeded()
        label.align(.top, to: view, inset: baseTop + (cardCellHeight - 140) / 4 - label.frame.height / 2)
        let leftImageView = UIImageView(image: #imageLiteral(resourceName: "TapGesture"))
        let rightImageView = UIImageView(image: #imageLiteral(resourceName: "TapGesture"))
        view.addSubview(leftImageView)
        leftImageView.centerX(to: view, offset: -view.frame.size.width / 4)
        leftImageView.align(.top, to: view, inset: baseTop + (cardCellHeight - 140) / 2 - leftImageView.frame.height / 2)
        view.addSubview(rightImageView)
        rightImageView.centerX(to: view, offset: view.frame.size.width / 4)
        rightImageView.align(.top, to: leftImageView)
    }
}

