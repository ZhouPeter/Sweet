//
//  Guide+Guide+SameCardChoiceTip.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension Guide {
    class func showSameCardChoiceTip(with rect: CGRect) {
        let guide = Guide()
        let view = guide.rootView
        let focusView = FocusView(focusRect: rect)
        view.addSubview(focusView)
        focusView.fill(in: view)
        let label = UILabel()
        label.text = "这些人也发表了表情"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        view.addSubview(label)
        label.centerX(to: view)
        label.align(.bottom, to: view, inset: view.bounds.height - rect.minY + 20)
    }
}
