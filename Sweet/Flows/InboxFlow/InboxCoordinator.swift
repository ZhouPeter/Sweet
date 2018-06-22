//
//  InboxCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import PKHUD

final class InboxCoordinator: BaseCoordinator {
    private let factory: ContactsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let token: String
    private let storage: Storage
    private var conversations = [Conversation]()
    private var inboxView: InboxView?
    private var isOffline = true
    
    init(user: User,
         token: String,
         router: Router,
         factory: ContactsFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
        self.router = router
        self.token = token
        self.storage = Storage(userID: user.userId)
    }
    
    func start(with view: InboxView) {
        view.delegate = self
        inboxView = view
        Messenger.shared.addDelegate(self)
        Messenger.shared.login(with: user, token: token)
    }
    
    override func start() {
        if isOffline && Messenger.shared.state == .online {
            isOffline = false
            Messenger.shared.loadConversations()
        }
    }
}

extension InboxCoordinator: InboxViewDelegate {
    func inboxRemoveConversation(_ conversation: Conversation) {
        Messenger.shared.removeConversation(userID: conversation.user.userId)
    }
    
    func inboxStartConversation(_ conversation: Conversation) {
        Messenger.shared.markConversationAsRead(userID: conversation.user.userId)
        let controller = ConversationController(user: user, buddy: conversation.user)
        controller.delegate = self
        router.push(controller)
    }
}

extension InboxCoordinator: ConversationControllerDelegate {
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
                logger.debug()
                PKHUD.toast(message: "举报成功")
            }
        }
    }
    
    func conversationController(_ controller: ConversationController, blocksBuddy buddy: User) {
        web.request(.addBlacklist(userId: buddy.userId)) { (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
                PKHUD.toast(message: "操作失败")
            case .success:
                logger.debug()
                self.storage.write({ (realm) in
                    if let user = realm.object(ofType: UserData.self, forPrimaryKey: buddy.userId) {
                        user.isBlacklisted = true
                    }
                }, callback: { (_) in
                    Messenger.shared.loadConversations()
                })
                PKHUD.toast(message: "将不再收到该用户的任何信息", duration: 1, completion: {
                    controller.didBlock()
                })
            }
        }
    }
    
    func conversationController(_ controller: ConversationController, unblocksBuddy buddy: User) {
        web.request(.delBlacklist(userId: buddy.userId)) { (result) in
            switch result {
            case .failure(let error):
                logger.error(error)
                PKHUD.toast(message: "操作失败")
            case .success:
                logger.debug()
                self.storage.write({ (realm) in
                    if let user = realm.object(ofType: UserData.self, forPrimaryKey: buddy.userId) {
                        user.isBlacklisted = false
                    }
                }, callback: { (_) in
                    Messenger.shared.loadConversations()
                })
                PKHUD.toast(message: "将不再收到该用户的任何信息", duration: 1, completion: nil)
            }
        }
    }
    
    func conversationControllerShowsStory(_ viewModel: StoryCellViewModel, user: User) {
        
    }
}

extension InboxCoordinator: MessengerDelegate {
    func messengerDidLogin(user: User, success: Bool) {
        logger.debug(user.nickname, success)
        start()
    }
    
    func messengerDidLogout(user: User) {
        logger.debug(user.nickname)
        isOffline = true
    }
    
    func messengerDidUpdateState(_ state: MessengerState) {
        logger.debug(state)
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        logger.debug(message.rawContent, success)
    }
    
    func messengerDidUpdateConversations(_ conversations: [Conversation]) {
        inboxView?.didUpdateConversations(conversations)
    }
}
