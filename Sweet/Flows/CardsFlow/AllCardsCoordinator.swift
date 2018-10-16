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
    private let storage: Storage
    private var allView: CardsAllView?
    init(user: User, router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.router = router
        self.factory = factory
        self.storage = Storage(userID: user.userId)
        self.coordinatorFactory = coordinatorFactory
    }
    
    func start(with allView: CardsAllView) {
        allView.delegate = self
        self.allView = allView
    }
    
    private func startConversationWith(group: Group) {
        var conversation: IMConversation? = nil
        storage.read({(realm) in
            if let conversationData = ConversationData.object(in: realm, id: group.id, isGroup: true) {
                conversation = conversationData.makeIMConversation()
            }
        }) {
            let coordinator = GroupConversationCoordinator(user: self.user,
                                                           group: group,
                                                           conversation: conversation,
                                                           router: self.router,
                                                           coordinatorFactory: self.coordinatorFactory)
            coordinator.finishFlow = { [weak self] in self?.removeDependency(coordinator) }
            self.addDependency(coordinator)
            coordinator.start()
        }
       
    }
}

extension AllCardsCoordinator: LikeRankListViewDelegate {
    
}

extension AllCardsCoordinator: CardsBaseViewDelegate {
    func showGroupConversation(groupId: UInt64) {
        Messenger.shared.loadGroupWith(id: groupId) { [weak self] (group) in
            guard let group = group else {
                logger.error("Group is nil")
                return
            }
            self?.startConversationWith(group: group)
        }
    }
    
    func showLikeRankList(title: String) {
        let controller = LikeRankListController(title: title)
        controller.delegate = self
        router.push(controller.toPresent())
    }
    
    
    func showStoriesGroup(storiesGroup: [[StoryCellViewModel]],
                          currentIndex: Int, fromCardId: String?,
                          delegate: StoriesPlayerGroupViewControllerDelegate?,
                          completion: (() -> Void)?) {
        let navigation = FunNavigationViewController()
        navigation.hero.isEnabled = true
        let coordinator = coordinatorFactory.makeStoryPlayerCoordinator(user: user,
                                                                        navigation: navigation,
                                                                        current: currentIndex,
                                                                        currentStart: 0,
                                                                        fromCardId: fromCardId,
                                                                        storiesGroup: storiesGroup,
                                                                        delegate: delegate)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
        
    }
    
    func showProfile(buddyID: UInt64, setTop: SetTop? = nil) {
        let coordinator = coordinatorFactory.makeProfileCoordinator(user: user,
                                                                    buddyID: buddyID,
                                                                    setTop: setTop,
                                                                    router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
