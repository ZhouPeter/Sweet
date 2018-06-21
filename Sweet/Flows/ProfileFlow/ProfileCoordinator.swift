//
//  ProfileCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol ProfileCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

class ProfileCoordinator: BaseCoordinator, ProfileCoordinatorOutput {
    var finishFlow: (() -> Void)?
    private let factory: ProfileFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let userID: UInt64
    
    init(user: User,
         userID: UInt64,
         router: Router,
         factory: ProfileFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.userID = userID
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        showProfile()
    }
    
    // MARK: - Private
    private func showProfile() {
        let profile = factory.makeProfileView(user: user, userId: userID)
        profile.showAbout = { [weak self] (user) in
            self?.showAbout(user: user)
        }
        profile.finished = { [weak self] in
            self?.finishFlow?()
        }
        profile.showStoriesPlayerView = { [weak self] (user, stories, current, delegate, completion) in
            self?.showStoriesPlayerView(user: user,
                                        stories: stories,
                                        current: current,
                                        delegate: delegate)
            
        }
        router.push(profile)
    }
    
    private func showStoriesPlayerView(user: User,
                                       stories: [StoryCellViewModel],
                                       current: Int,
                                       delegate: StoriesPlayerViewControllerDelegate) {
        let coordinator = coordinatorFactory.makeStoryPlayerCoordinator(user: user,
                                                                        router: router,
                                                                        current: current,
                                                                        isGroup: false,
                                                                        fromCardId: nil, 
                                                                        storiesGroup: [stories],
                                                                        delegate: delegate,
                                                                        groupDelegate: nil)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func showAbout(user: UserResponse) {
        let aboutOutput  = factory.makeProfileAboutOutput(user: user)
        aboutOutput.showWebView = { [weak self] (title, urlString) in
            self?.showWebView(title: title, urlString: urlString)
        }
        
        aboutOutput.showFeedback = { [weak self] in
            self?.showFeedback()
        }
        
        aboutOutput.showUpdate = { [weak self] (user) in
            self?.showUpdate(user: user)
        }
        router.push(aboutOutput)
    }
    
    private func showUpdate(user: UserResponse) {
        let updateOutput = factory.makeProfileUpdateOutput(user: user)
        router.push(updateOutput)
    }
    
    private func showWebView(title: String, urlString: String) {
        let webViewController = WebViewController(urlString: urlString)
        webViewController.navigationItem.title = title
        router.push(webViewController)
    }
    
    private func showFeedback() {
        let feedback = FeedbackController()
        router.push(feedback)
    }
}
