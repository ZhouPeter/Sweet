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
    private let window: SweetWindow
    private var retainClosure: (() -> Void)?
    var removeClosure: (() -> Void)?
    
    init() {
        window = SweetWindow(frame: UIScreen.main.bounds)
        rootView = UIView(frame: window.bounds)
        rootView.backgroundColor = .clear
        window.addSubview(rootView)
        rootView.fill(in: window)
        retainClosure = { _ = self }
        window.touched = { [weak self] in self?.dismiss() }
        window.windowLevel = UIWindowLevelAlert + 1
        window.makeKeyAndVisible()
        rootView.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.rootView.alpha = 1
        }, completion: nil)
    }
    
    private func dismiss() {
        UIView.animate(withDuration: 0.25, delay: 0, options: .curveEaseOut, animations: {
            self.rootView.alpha = 0
        }) { (_) in
            self.window.resignKey()
            self.removeClosure?()
            self.retainClosure = nil
        }
    }
}

private class SweetWindow: UIWindow {
    var touched: (() -> Void)?
    
    override func sendEvent(_ event: UIEvent) {
        if event.type == .touches {
            touched?()
        }
        super.sendEvent(event)
    }
}
