//
//  Guide.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class Guide {
    let rootView: UIView
    private let window: UIWindow
    private var retainClosure: (() -> Void)?
    var removeClosure: (() -> Void)?
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
        removeClosure?()
        retainClosure = nil
    }
}
