//
//  Router.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol Router: Presentable {
    
    func replaceController(parentController: UIViewController,
                           oldController: UIViewController,
                           newController: UIViewController)
    
    func present(_ flow: Presentable?)
    func present(_ flow: Presentable?, animated: Bool)
    
    func push(_ flow: Presentable?)
    func push(_ flow: Presentable?, animated: Bool)
    func push(_ flow: Presentable?, animated: Bool, completion: (() -> Void)?)
    
    func popFlow()
    func popFlow(animated: Bool)
    
    func dismissFlow()
    func dismissFlow(animated: Bool, completion: (() -> Void)?)
    
    func setRootFlow(_ flow: Presentable?)
    func setRootFlow(_ flow: Presentable?, hideBar: Bool)
    
    func popToRootFlow(animated: Bool)
    func setAsSecondFlow(_ flow: Presentable)
}
