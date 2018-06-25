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
    init(user: User,
         router: Router,
         factory: StoryPlayerFlowFactory,
         coordinatorFactory: CoordinatorFactory,
         storiesGroup: [[StoryCellViewModel]],
         current: Int = 0,
         currentStart: Int = 0,
         delegate: StoriesPlayerGroupViewControllerDelegate? = nil,
         isGroup: Bool = false,
         fromCardId: String? = nil) {
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
            delegate: delegate)
        storiesGroupView.onFinish = { [weak self] in
            self?.router.dismissFlow()
            self?.finishFlow?()
        }
        storiesGroupView.runStoryFlow = { [weak self] topic in
            self?.runStoryFlow(topic: topic, finishBlock: { [weak storiesGroupView] in
                storiesGroupView?.play()
            })
        }
        storiesGroupView.runProfileFlow = { [weak self] (user, buddyID) in
            self?.runProfileFlow(user: user, buddyID: buddyID)
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
        storiesPlayerView.runStoryFlow = { [weak self] topic in
            self?.runStoryFlow(topic: topic, finishBlock: { [weak storiesPlayerView] in
                storiesPlayerView?.play()
            })
        }
        storiesPlayerView.runProfileFlow = { [weak self] (user, buddyID) in
            self?.runProfileFlow(user: user, buddyID: buddyID)
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
    
    private func runProfileFlow(user: User, buddyID: UInt64) {
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory.makeProfileCoordinator(
            user: user,
            buddyID: buddyID,
            navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start(with: .present)
    }
}
