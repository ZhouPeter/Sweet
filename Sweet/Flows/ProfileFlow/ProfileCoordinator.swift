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

struct SetTop {
    let contentId: String?
    let preferenceId: UInt64?
}
class ProfileCoordinator: BaseCoordinator, ProfileCoordinatorOutput {
    var finishFlow: (() -> Void)?
    private let factory: ProfileFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let buddyID: UInt64
    private let setTop: SetTop?
    init(user: User,
         userID: UInt64,
         setTop: SetTop? = nil,
         router: Router,
         factory: ProfileFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.buddyID = userID
        self.setTop = setTop
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        start(with: nil)
    }
    override func start(with option: DeepLinkOption?) {
        if let option = option {
            showProfile(isPresent: option == .present)
        } else {
            showProfile()
        }
    }

    
    // MARK: - Private
    private func showProfile(isPresent: Bool = false) {
        let profile = factory.makeProfileView(user: user, userId: buddyID, setTop: setTop)
        profile.delegate = self
        profile.finished = { [weak self] in
            self?.finishFlow?()
        }
        profile.showStoriesPlayerView = { [weak self] (user, stories, current, delegate) in
            self?.showStoriesPlayerView(user: user,
                                        stories: stories,
                                        current: current,
                                        delegate: delegate)
            
        }
        profile.showStory = { [weak self] in
            self?.showStory()
        }
        profile.showProfile = { [weak self] (buddyID, setTop, finishBlock) in
            self?.showProfile(buddyID: buddyID, setTop: setTop, finishBlock: finishBlock)
        }
        if isPresent {
            router.setRootFlow(profile)
        } else {
            router.push(profile)
        }
    }
    
    private func showStory() {
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory
            .makeDismissableStoryCoordinator(user: user, topic: nil, navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
    }
   
    private func showProfile(buddyID: UInt64, setTop: SetTop?, finishBlock: (() -> Void)?) {
        let navigation = UINavigationController()
        let coordinator = coordinatorFactory.makeProfileCoordinator(
            user: user,
            buddyID: buddyID,
            setTop: setTop,
            navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
            finishBlock?()
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start(with: .present)
    }
    
    private func showStoriesPlayerView(user: User,
                                       stories: [StoryCellViewModel],
                                       current: Int,
                                       delegate: StoriesPlayerGroupViewControllerDelegate?) {
        let navigation = UINavigationController()
        var storiesGroup = [[StoryCellViewModel]]()
        var newCurrent = 0
        var newCurrentStart = 0
        if self.user.userId == buddyID {
            var beforeDay: String = ""
            var storiesByDay = [StoryCellViewModel]()
            var sumCount = 0
            for (index,story) in stories.enumerated() {
                let day = TimerHelper.storyTime(timeInterval: TimeInterval(story.created)).day
                if day == beforeDay {
                    storiesByDay.append(story)
                    if index == stories.count - 1 {
                        storiesGroup.append(storiesByDay)
                    }
                } else {
                    if storiesByDay.count > 0 {
                        storiesGroup.append(storiesByDay)
                        storiesByDay.removeAll()
                    }
                    storiesByDay.append(story)
                    if index == stories.count - 1 {
                        storiesGroup.append(storiesByDay)
                    }
                }
                beforeDay = day
            }
            for (index, stories) in storiesGroup.enumerated() {
                sumCount += stories.count
                if sumCount > current {
                    newCurrent = index
                    newCurrentStart = stories.count - (sumCount - (current + 1)) - 1
                    break
                }
            }
        } else {
            newCurrentStart = current
            newCurrent = 0
            storiesGroup = [stories]
        }
        
        let coordinator = coordinatorFactory.makeStoryPlayerCoordinator(
            user: user,
            navigation: navigation,
            current: newCurrent,
            currentStart: newCurrentStart,
            fromCardId: nil,
            storiesGroup: storiesGroup,
            delegate: delegate)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
    }
    
    private func showUpdate(user: UserResponse, updateRemain: UpdateRemainResponse) {
        let updateOutput = factory.makeProfileUpdateOutput(user: user, updateRemain: updateRemain)
        router.push(updateOutput)
    }
    
    private func showSetting(setting: UserSetting) {
        let settingOutput = UpdateSettingsController(setting: setting)
        router.push(settingOutput)
    }
    
    private func showWebView(title: String, urlString: String) {
        let webViewController = WebViewController(urlString: urlString)
        router.push(webViewController)
    }
    
    private func showFeedback() {
        let feedback = FeedbackController()
        router.push(feedback)
    }
}


extension ProfileCoordinator: ProfileViewDelegate {
    func showAbout(user: UserResponse, updateRemain: UpdateRemainResponse, setting: UserSetting) {
        let aboutOutput  = factory.makeProfileAboutOutput(user: user, updateRemain: updateRemain, setting: setting)
        aboutOutput.showWebView = { [weak self] (title, urlString) in
            self?.showWebView(title: title, urlString: urlString)
        }
        
        aboutOutput.showFeedback = { [weak self] in
            self?.showFeedback()
        }
        
        aboutOutput.showUpdate = { [weak self] (user, updateRemain) in
            self?.showUpdate(user: user, updateRemain: updateRemain)
        }
        aboutOutput.showSetting = { [weak self] (setting) in
            self?.showSetting(setting: setting)
        }
        router.push(aboutOutput)
    }

    func showConversation(user: User, buddy: User) {
        let coordinator = ConversationCoordinator(
            user: user,
            buddy: buddy,
            router: router,
            coordinatorFactory: coordinatorFactory)
        coordinator.finishFlow = { [weak self] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
