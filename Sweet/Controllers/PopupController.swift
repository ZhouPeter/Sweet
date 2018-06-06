//
//  PopupController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import STPopup

class PopupController {
    private let popupController: STPopupController
    private var retainClosure: (() -> Void)?
    
    init(rootViewController: UIViewController) {
        popupController = STPopupController(rootViewController: rootViewController)
        let blurEffect = UIBlurEffect(style: .light)
        popupController.backgroundView = UIVisualEffectView(effect: blurEffect)
        popupController.containerView.layer.cornerRadius = 10
        popupController.transitionStyle = .fade
        popupController.hidesCloseButton = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        popupController.backgroundView?.addGestureRecognizer(tap)
        retainClosure = { _ = self }
    }
    
    func present(in presenting: UIViewController, completion: (() -> Void)? = nil) {
        popupController.present(in: presenting, completion: completion)
    }
    
    @objc private func didTap() {
        popupController.dismiss { [weak self] in self?.retainClosure = nil }
    }
}
