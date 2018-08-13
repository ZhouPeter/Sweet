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
    
    func selectIMFlow()
}

final class MainCoordinator: BaseCoordinator {
    private let user: User
    private let token: String
    private let mainView: MainView
    private let coordinatorFactory: CoordinatorFactory
    
    init(user: User, token: String, mainView: MainView, coordinatorFactory: CoordinatorFactory) {
        self.user = user
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
    deinit {
        logger.debug("main coordinator 释放")
    }
    
    // MARK: - Private
 
    private func runCardsFlow() -> ((UINavigationController) -> Void) {
        return { [weak self] nav in
            guard let `self` = self, nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory.makeCardsCoordinator(user: self.user, navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
    
    private func runStoryFlow() -> ((UINavigationController) -> Void) {
        return { [weak self] nav in
            guard let `self` = self, nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory.makeStoryCoordinator(user: self.user, navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
    
    private func runIMFlow() -> ((UINavigationController) -> Void) {
        return { [weak self] nav in
            guard let `self` = self, nav.viewControllers.isEmpty else { return }
            let coordinator = self.coordinatorFactory
                .makeIMCoordinator(user: self.user, token: self.token, navigation: nav)
            coordinator.start()
            self.addDependency(coordinator)
        }
    }
}
