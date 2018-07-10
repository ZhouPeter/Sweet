//
//  StoryPlayerCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/21.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryPlayerCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

final class StoryPlayerCoordinator: BaseCoordinator, StoryPlayerCoordinatorOutput {
    var finishFlow: (() -> Void)?
    private let factory: StoryPlayerFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let storiesGroup: [[StoryCellViewModel]]
    private let current: Int
    private let currentStart: Int
    private let isGroup: Bool
    private weak var delegate: StoriesPlayerGroupViewControllerDelegate?
    private weak var playerDelegate: StoriesPlayerViewControllerDelegate?
    private let fromCardId: String?
    private let fromUserId: UInt64?
    private let fromMessageId: String?
    init(user: User,
         router: Router,
         factory: StoryPlayerFlowFactory,
         coordinatorFactory: CoordinatorFactory,
         storiesGroup: [[StoryCellViewModel]],
         current: Int = 0,
         currentStart: Int = 0,
         delegate: StoriesPlayerGroupViewControllerDelegate? = nil,
         isGroup: Bool = false,
         fromCardId: String? = nil,
         fromUserId: UInt64? = nil,
         fromMessageId: String? = nil) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
        self.storiesGroup = storiesGroup
        self.current = current
        self.currentStart = currentStart
        self.isGroup = isGroup
        self.delegate = delegate
        self.fromCardId = fromCardId
        self.fromUserId = fromUserId
        self.fromMessageId = fromMessageId
    }
    
    override func start() {
        if isGroup {
            showStoriesGroupView()
        } else {
            showStoriesGroupView()
        }
    }
    
}

extension StoryPlayerCoordinator {
    private func showStoriesGroupView() {
        let storiesGroupView = factory.makeStoiesGroupView(
            user: user,
            storiesGroup: storiesGroup,
            currentIndex: current,
            currentStart: currentStart,
            fromCardId: fromCardId,
            fromMessageId:  fromMessageId,
            delegate: delegate)
        storiesGroupView.onFinish = { [weak self] in
            self?.router.dismissFlow()
            self?.finishFlow?()
        }
        storiesGroupView.runStoryFlow = { [weak self, weak storiesGroupView] topic in
            storiesGroupView?.pause()
            self?.runStoryFlow(topic: topic, finishBlock: {
                storiesGroupView?.play()
            })
        }
        storiesGroupView.runProfileFlow = { [weak self, weak storiesGroupView] (user, buddyID) in
            storiesGroupView?.pause()
            self?.runProfileFlow(user: user, buddyID: buddyID, finishBlock: {
                storiesGroupView?.play()
            })
        }
        router.setRootFlow(storiesGroupView)
    }
    
    private func showStoriesPlayerView() {
        let storiesPlayerView = factory.makeStoriesPlayerView(
            user: user,
            stories: storiesGroup[0],
            current: current,
            delegate: playerDelegate)
        storiesPlayerView.onFinish = { [weak self] in
            self?.router.popFlow()
            self?.finishFlow?()
        }
        storiesPlayerView.runStoryFlow = { [weak self, weak storiesPlayerView] topic in
            storiesPlayerView?.pause()
            self?.runStoryFlow(topic: topic, finishBlock: {
                storiesPlayerView?.play()
            })
        }
        storiesPlayerView.runProfileFlow = { [weak self, weak storiesPlayerView] (user, buddyID) in
            storiesPlayerView?.pause()
            self?.runProfileFlow(user: user, buddyID: buddyID, finishBlock: {
                storiesPlayerView?.play()
            })
        }
        _ = storiesPlayerView.toPresent()?.view
        storiesPlayerView.reloadPlayer()
        router.setRootFlow(storiesPlayerView)
    }
    
    private func runStoryFlow(topic: String, finishBlock: (() -> Void)?){
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory
            .makeDismissableStoryCoordinator(user: user, topic: topic, navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            finishBlock?()
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
    }
    
    private func runProfileFlow(user: User, buddyID: UInt64, finishBlock: (() -> Void)?) {
        if buddyID == fromUserId {
            self.router.dismissFlow()
            self.finishFlow?()
            return
        }
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory.makeProfileCoordinator(
            user: user,
            buddyID: buddyID,
            navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            finishBlock?()
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start(with: .present)
    }
}
