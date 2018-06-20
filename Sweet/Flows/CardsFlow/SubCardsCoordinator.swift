//
//  SubCardsCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class SubCardsCoordinator: BaseCoordinator {
    private let factory: CardsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private var subView: CardsSubscriptionView?
    init(user: User, router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start(with subView: CardsSubscriptionView) {
        subView.delegate = self
        self.subView = subView
    }
}

extension SubCardsCoordinator {
    func runStoryFlow(topic: String) {
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory
            .makeDismissableStoryCoordinator(user: user, topic: topic, navigation: navigation)
        coordinator.finishFlow = { [weak self, coordinator] in
            self?.removeDependency(coordinator)
            logger.debug()
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
    }
}

extension SubCardsCoordinator: CardsBaseViewDelegate {
    func showStoriesGroup(user: User, storiesGroup: [[StoryCellViewModel]],
                          currentIndex: Int, fromCardId: String?,
                          delegate: StoriesPlayerGroupViewControllerDelegate,
                          completion: (() -> Void)?) {
        let storiesGroupView = factory.makeStoiesGroupView(user: user,
                                                           storiesGroup: storiesGroup,
                                                           currentIndex: currentIndex,
                                                           fromCardId: fromCardId,
                                                           delegate: delegate)
        storiesGroupView.runStoryFlow = { [weak self] topic in
            self?.runStoryFlow(topic: topic)
        }
        router.present(storiesGroupView, animated: true, completion: completion)
        
    }
    
    func showProfile(userId: UInt64) {
        let coordinator = self.coordinatorFactory.makeProfileCoordinator(user: user, userID: userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
