//
//  GroupConversationCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/19.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation
import PKHUD

protocol GroupConversationCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class GroupConversationCoordinator: BaseCoordinator, ConversationCoordinatorOuput {
    var finishFlow: (() -> Void)?
    
    private let user: User
    private let group: Group
    private let router: Router
    private let coordinatorFactory: CoordinatorFactory
    private let storage: Storage
    private var conversation: IMConversation?
    
    init(user: User, group: Group, conversation: IMConversation? = nil, router: Router, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.group = group
        self.router = router
        self.conversation = conversation
        self.coordinatorFactory = coordinatorFactory
        self.storage = Storage(userID: user.userId)
    }
    
    override func start() {
        let controller = GroupConversationController(user: user, group: group, conversation: conversation)
        controller.delegate = self
        router.push(controller)
        Messenger.shared.startConversation(group.id)
        if let conversation = conversation {        
            Messenger.shared.markConversationAsRead(conversation)
        }
    }
}

extension GroupConversationCoordinator: ConversationControllerDelegate {
    func conversationControllerShowsProfile(buddyID: UInt64, setTop: SetTop?) {
        let navigation = UINavigationController()
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, buddyID: buddyID, setTop: setTop, navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start(with: .present)
    }
    
    func conversationControllerShowsProfile(buddyID: UInt64) {
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, buddyID: buddyID, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
    
    func conversationControllerShowsProfile(buddy: User) {
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, buddyID: buddy.userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
    
    func conversationControllerShowsShareWebView(url: String, cardId: String) {
        let webView = ShareWebViewController(urlString: url, cardId: cardId)
        webView.delegate = self
        router.push(webView)
    }
    
    func conversationControllerShowsStory(_ viewModel: StoryCellViewModel, user: User, messageId: String) {
        let navigation = UINavigationController()
        navigation.hero.isEnabled = true
        let coordinator = coordinatorFactory.makeStoryPlayerCoordinator(
            user: user,
            navigation: navigation,
            fromMessageId: messageId,
            storiesGroup: [[viewModel]])
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start()
    }
    
    func conversationDidFinish() {
        Messenger.shared.endConversation(group.id)
        finishFlow?()
    }
}

extension GroupConversationCoordinator: ShareWebViewControllerDelegate {
    func showProfile(userId: UInt64, webView: ShareWebViewController) {
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, buddyID: userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
}
