//
//  Guide.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension Guide {
    class func showSwipeTips(_ tips: String) {
        let guide = Guide()
        let imageView = UIImageView(image: #imageLiteral(resourceName: "SwipeGesture"))
        let label = UILabel()
        label.text = tips
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
    
    class func showStoryRecordTips() {
        let guide = Guide()
        let title = UILabel()
        title.text = "小故事相机"
        title.font = UIFont.boldSystemFont(ofSize: 24)
        title.textColor = .white
        title.textAlignment = .center
        let content = UILabel()
        content.numberOfLines = 0
        content.text =
"""
记录生活点滴

向朋友们展示 3 天

3 天后仅自己可见
"""
        content.textAlignment = .center
        content.textColor = .white
        content.font = UIFont.systemFont(ofSize: 20)
        let button = UIButton()
        button.backgroundColor = .white
        button.setTitle("立即开始", for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.setTitleColor(.black, for: .normal)
        button.backgroundColor = .white
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.isUserInteractionEnabled = false
        let view = guide.rootView
        let mask = UIView()
        mask.backgroundColor = .black
        mask.alpha = 0.6
        view.addSubview(mask)
        view.addSubview(title)
        view.addSubview(content)
        view.addSubview(button)
        mask.fill(in: view)
        title.align(.top, to: view, inset: 150)
        title.centerX(to: view)
        content.pin(.bottom, to: title, spacing: 45)
        content.centerX(to: view)
        button.constrain(width: 120, height: 40)
        button.centerX(to: view)
        button.align(.bottom, to: view, inset: 150)
    }
}

class Guide {
    let rootView: UIView
    private let window: UIWindow
    private var retainClosure: (() -> Void)?
    
    init() {
        window = UIWindow(frame: UIScreen.main.bounds)
        rootView = UIView(frame: window.bounds)
        rootView.backgroundColor = .clear
        window.addSubview(rootView)
        rootView.fill(in: window)
        retainClosure = { _ = self }
        rootView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(tapped)))
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
    }
    
    @objc private func tapped() {
        window.resignKey()
        retainClosure = nil
    }
}
