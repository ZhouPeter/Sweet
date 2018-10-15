//
//  BaseViewController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    var automaticallyDisablePageScroll = true
    var isHiddenBackItemTitle = true
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        if isHiddenBackItemTitle {
            let backBarButtonItem = UIBarButtonItem()
            backBarButtonItem.title = ""
            navigationItem.backBarButtonItem = backBarButtonItem
        }
    }
    
    override var shouldAutorotate: Bool {
        return false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoDisablePageScroll()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        autoDisablePageScroll()
    }
    

    
    private func autoDisablePageScroll() {
        guard automaticallyDisablePageScroll, let count = navigationController?.viewControllers.count else { return }
        if count == 1 {
            NotificationCenter.default.post(name: .EnablePageScroll, object: nil)
        } else {
            NotificationCenter.default.post(name: .DisablePageScroll, object: nil)
        }
    }
}
