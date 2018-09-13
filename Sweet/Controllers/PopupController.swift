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
        let backgroundView = UIView()
        backgroundView.backgroundColor = .black
        let returnImageView = UIImageView(image: #imageLiteral(resourceName: "Return"))
        backgroundView.addSubview(returnImageView)
        returnImageView.align(.left, inset: 10)
        returnImageView.align(.top, inset: UIScreen.isNotched() ? 54 : 20)
        returnImageView.constrain(width: 30, height: 30)
        popupController.backgroundView = backgroundView
        popupController.containerView.layer.cornerRadius = 10
        popupController.transitionStyle = .fade
        popupController.hidesCloseButton = true
        let backgroundTap = UITapGestureRecognizer(target: self, action: #selector(didTap))
        popupController.backgroundView?.addGestureRecognizer(backgroundTap)
        let containerPan = CustomPanGestureRecognizer(orientation: .down, target: self, action: #selector(didDownPan))
        popupController.containerView.addGestureRecognizer(containerPan)
        retainClosure = { _ = self }
    }
    
    func present(in presenting: UIViewController, completion: (() -> Void)? = nil) {
        popupController.present(in: presenting, completion: completion)
    }
    
    @objc private func didTap() {
        popupController.dismiss { [weak self] in self?.retainClosure = nil }
    }
    
    @objc private func didDownPan() {
        popupController.dismiss { [weak self] in self?.retainClosure = nil }
    }
}
