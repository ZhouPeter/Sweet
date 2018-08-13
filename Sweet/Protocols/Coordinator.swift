//
//  Coordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

protocol Coordinator: class {
    func start()
    func start(with option: DeepLinkOption?)
}

class BaseCoordinator: Coordinator {
    var childCoordinators = [Coordinator]()
    
    func start() {
        start(with: nil)
    }
    
    func start(with option: DeepLinkOption?) {}
    
    func addDependency(_ coordinator: Coordinator) {
        for element in childCoordinators where element === coordinator { return }
        childCoordinators.append(coordinator)
    }
    
    func removeDependency(_ coordinator: Coordinator?) {
        guard childCoordinators.isNotEmpty, let coordinator = coordinator else { return }
        for (index, element) in childCoordinators.enumerated() where element === coordinator {
            childCoordinators.remove(at: index)
            break
        }
    }
    
    func removeAllDependency() {
        guard childCoordinators.isNotEmpty else { return }
        childCoordinators.removeAll()
    }
    
}
