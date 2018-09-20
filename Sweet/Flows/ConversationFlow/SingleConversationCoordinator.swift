//
//  ConversationCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import PKHUD

protocol ConversationCoordinatorOuput {
    var finishFlow: (() -> Void)? { get set }
}

final class SingleConversationCoordinator: BaseCoordinator, ConversationCoordinatorOuput {
    var finishFlow: (() -> Void)?
    
    private let user: User
    private var buddy: User
    private let router: Router
    private let coordinatorFactory: CoordinatorFactory
    private let storage: Storage
    
    init(user: User, buddy: User, router: Router, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.buddy = buddy
        self.router = router
        self.coordinatorFactory = coordinatorFactory
        self.storage = Storage(userID: user.userId)
    }
    
    override func start() {
        Messenger.shared.markConversationAsRead(buddy.userId, isGroup: false)
        let conversation = SingleConversationController(user: user, buddy: buddy)
        conversation.delegate = self
        router.push(conversation)
        Messenger.shared.startConversation(buddy.userId)
    }
}

extension SingleConversationCoordinator: ConversationControllerDelegate {
    func conversationControllerShowsProfile(buddyID: UInt64, setTop: SetTop?) {
        let navigation = UINavigationController()
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, buddyID: buddyID, setTop: setTop, navigation: navigation)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        router.present(navigation, animated: true)
        coordinator.start(with: .present)
    }
    
    func conversationControllerShowsShareWebView(url: String, cardId: String) {
        let webView = ShareWebViewController(urlString: url, cardId: cardId)
        webView.delegate = self
        router.push(webView)
    }
    
    func conversationControllerShowsProfile(buddy: User) {
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, userID: buddy.userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
    
    func conversationControllerReports(buddy: User) {
        web.request(.reportUser(userID: buddy.userId)) { (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
                PKHUD.toast(message: "举报失败")
            case .success:
                PKHUD.toast(message: "举报成功")
            }
        }
    }
    
    func conversationController(_ controller: ConversationViewController, blocksBuddy buddy: User) {
        web.request(.addBlacklist(userId: buddy.userId)) { (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
                PKHUD.toast(message: "操作失败")
            case .success:
                self.storage.write({ (realm) in
                    if let user = realm.object(ofType: UserData.self, forPrimaryKey: buddy.userId) {
                        user.isBlacklisted = true
                    }
                }, callback: { (_) in
                    Messenger.shared.loadConversations()
                })
                PKHUD.toast(message: "将不再收到该用户的任何信息", duration: 1, completion: {
                    controller.didBlock(userID: buddy.userId)
                })
            }
        }
    }
    
    func conversationController(_ controller: ConversationViewController, unblocksBuddy buddy: User) {
        web.request(.delBlacklist(userId: buddy.userId)) { (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
                PKHUD.toast(message: "操作失败")
            case .success:
                self.storage.write({ (realm) in
                    if let user = realm.object(ofType: UserData.self, forPrimaryKey: buddy.userId) {
                        user.isBlacklisted = false
                    }
                }, callback: { (_) in
                    Messenger.shared.loadConversations()
                })
                PKHUD.toast(message: "将不再收到该用户的任何信息", duration: 1, completion: {
                    controller.didUnblock(userID: buddy.userId)
                })
            }
        }
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
        Messenger.shared.endConversation()
        finishFlow?()
    }
}

extension SingleConversationCoordinator: ShareWebViewControllerDelegate {
    func showProfile(userId: UInt64, webView: ShareWebViewController) {
        let coordinator = self.coordinatorFactory
            .makeProfileCoordinator(user: user, userID: userId, router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
}
