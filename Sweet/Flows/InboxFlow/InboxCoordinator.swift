//
//  InboxCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

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
        router.push(controller)
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
        logger.debug(message.content, success)
    }
    
    func messengerDidUpdateConversations(_ conversations: [Conversation]) {
        inboxView?.didUpdateConversations(conversations)
    }
}
