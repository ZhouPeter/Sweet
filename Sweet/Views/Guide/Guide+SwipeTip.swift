//
//  Guide+SwipeTip.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension Guide {
    class func showSwipeTip(_ tip: String) {
        let guide = Guide()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "SwipeGesture"))
        let label = UILabel()
        label.text = tip
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .white
        label.textAlignment = .center
        let view = guide.rootView
        let mask = UIView()
        mask.backgroundColor = .black
        mask.alpha = 0.6
        view.addSubview(mask)
        view.addSubview(imageView)
        view.addSubview(label)
        mask.fill(in: view)
        imageView.constrain(width: 100, height: 100)
        imageView.centerX(to: view)
        imageView.centerY(to: view, offset: -100)
        label.centerX(to: view)
        label.pin(.bottom, to: imageView, spacing: 10)
    }
}
