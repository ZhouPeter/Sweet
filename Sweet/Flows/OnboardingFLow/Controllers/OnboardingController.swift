//
//  OnboardingController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class OnboardingController: BaseViewController, OnboardingView {
    var onFinish: (() -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let button = UIButton(type: .system)
        button.setTitle("引导页", for: .normal)
        button.addTarget(self, action: #selector(didPressButton), for: .touchUpInside)
        view.addSubview(button)
        button.center(in: view, width: 50, height: 50)
    }
    
    @objc private func didPressButton() {
        onFinish?()
    }
}
