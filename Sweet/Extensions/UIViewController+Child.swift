//
//  UIViewController+Child.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIViewController {
    func add(childViewController: UIViewController) {
        addChildViewController(childViewController)
        childViewController.didMove(toParentViewController: self)
        childViewController.view.frame = view.bounds
        view.addSubview(childViewController.view)
    }
    
    func remove(childViewController: UIViewController) {
        childViewController.willMove(toParentViewController: nil)
        childViewController.view.removeFromSuperview()
        childViewController.removeFromParentViewController()
        childViewController.didMove(toParentViewController: nil)
    }
}
