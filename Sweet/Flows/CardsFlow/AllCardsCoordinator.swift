//
//  AllCardsCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AllCardsCoordinator: BaseCoordinator {
    private let factory: CardsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private var allView: CardsAllView?
    init(user: User, router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start(with allView: CardsAllView) {
        allView.delegate = self
        self.allView = allView
    }
}

extension AllCardsCoordinator: CardsBaseViewDelegate {
    func showStoriesGroup(user: User, storiesGroup: [[StoryCellViewModel]],
                          currentIndex: Int, fromCardId: String?,
                          delegate: StoriesPlayerGroupViewControllerDelegate,
                          completion: (() -> Void)?) {
        let navigation = UINavigationController()
        navigation.hero.isEnabled = true
        let coordinator = coordinatorFactory.makeStoryPlayerCoordinator(user: user,
                                                                        navigation: navigation,
                                                                        current: currentIndex,
                                                                        isGroup: true,
                                                                        fromCardId: fromCardId,
                                                                        storiesGroup: storiesGroup,
                                                                        delegate: nil,
                                                                        groupDelegate: delegate)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
        
    }
    
    func showProfile(userId: UInt64) {
        let coordinator = coordinatorFactory.makeProfileCoordinator(user: user, userID: userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
