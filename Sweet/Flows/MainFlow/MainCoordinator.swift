//
//  MainCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol MainView: BaseView {
    var userID: UInt64 { get set }
    var token: String { get set }
    var onStoryFlowSelect: ((UINavigationController) -> Void)? { get set }
    var onViewDidLoad: ((UINavigationController) -> Void)? { get set }
    var onCardsFlowSelect: ((UINavigationController) -> Void)? { get set }
    var onIMFlowSelect: ((UINavigationController) -> Void)? { get set }
}

final class MainCoordinator: BaseCoordinator {
    private let userID: UInt64
    private let token: String
    private let mainView: MainView
    private let coordinatorFactory: CoordinatorFactory
    private lazy var storage = Storage(userID: self.userID)
    
    init(userID: UInt64, token: String, mainView: MainView, coordinatorFactory: CoordinatorFactory) {
        self.userID = userID
        self.token = token
        self.mainView = mainView
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        mainView.onIMFlowSelect = runIMFlow()
        mainView.onViewDidLoad = runCardsFlow()
        mainView.onCardsFlowSelect = runCardsFlow()
        mainView.onStoryFlowSelect = runStoryFlow()
    }
    
    // MARK: - Private
 
    private func runCardsFlow() -> ((UINavigationController) -> Void) {
        return { nav in
            guard nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory.makeCardsCoordinator(navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
    
    private func runStoryFlow() -> ((UINavigationController) -> Void) {
        return { nav in
            guard nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory.makeStoryCoordinator(navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
    
    private func runIMFlow() -> ((UINavigationController) -> Void) {
        return { nav in
            guard nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory
                .makeIMCoordinator(token: self.token, storage: self.storage, navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
    
}
