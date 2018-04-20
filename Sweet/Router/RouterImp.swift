//
//  RouterImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class RouterImp: NSObject, Router {
    
    private weak var rootController: UINavigationController?
    private var completions: [UIViewController : () -> Void]
    
    init(rootController: UINavigationController) {
        self.rootController = rootController
        completions = [:]
    }
    
    func toPresent() -> UIViewController? {
        return rootController
    }
    
    func present(_ flow: Presentable?) {
        present(flow, animated: true)
    }
    
    func present(_ flow: Presentable?, animated: Bool) {
        guard let controller = flow?.toPresent() else { return }
        rootController?.present(controller, animated: animated, completion: nil)
    }
    
    func dismissFlow() {
        dismissFlow(animated: true, completion: nil)
    }
    
    func dismissFlow(animated: Bool, completion: (() -> Void)?) {
        rootController?.dismiss(animated: animated, completion: completion)
    }
    
    func push(_ flow: Presentable?) {
        push(flow, animated: true)
    }
    
    func push(_ flow: Presentable?, animated: Bool) {
        push(flow, animated: animated, completion: nil)
    }
    
    func push(_ flow: Presentable?, animated: Bool, completion: (() -> Void)?) {
        guard
            let controller = flow?.toPresent(),
            (controller is UINavigationController == false)
            else { assertionFailure("Deprecated push UINavigationController."); return }
        
        if let completion = completion {
            completions[controller] = completion
        }
        rootController?.pushViewController(controller, animated: animated)
    }
    
    func popFlow() {
        popFlow(animated: true)
    }
    
    func popFlow(animated: Bool) {
        if let controller = rootController?.popViewController(animated: animated) {
            runCompletion(for: controller)
        }
    }
    
    func setRootFlow(_ flow: Presentable?) {
        setRootFlow(flow, hideBar: false)
    }
    
    func setRootFlow(_ flow: Presentable?, hideBar: Bool) {
        guard let controller = flow?.toPresent() else { return }
        rootController?.setViewControllers([controller], animated: false)
        rootController?.isNavigationBarHidden = hideBar
    }
    
    func popToRootFlow(animated: Bool) {
        if let controllers = rootController?.popToRootViewController(animated: animated) {
            controllers.forEach { controller in
                runCompletion(for: controller)
            }
        }
    }
    
    private func runCompletion(for controller: UIViewController) {
        guard let completion = completions[controller] else { return }
        completion()
        completions.removeValue(forKey: controller)
    }
}
