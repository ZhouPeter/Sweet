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
    private let token: String
    private let storage: Storage
    private var conversations = [Conversation]()
    private var inboxView: InboxView?
    
    init(token: String,
         storage: Storage,
         router: Router,
         factory: ContactsFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
        self.router = router
        self.token = token
        self.storage = storage
    }
    
    func start(with view: InboxView) {
        view.delegate = self
        inboxView = view
        Messenger.shared.addDelegate(self)
        Messenger.shared.login(with: storage.userID, token: token)
    }
    
    override func start() {
        Messenger.shared.loadConversations()
    }
}

extension InboxCoordinator: InboxViewDelegate {
    func inboxRemoveConversation(userID: UInt64) {
        Messenger.shared.removeConversation(userID: userID)
    }
    
    func inboxStartConversation(_ conversation: Conversation) {
        let controller = ConversationController(userID: storage.userID, buddyID: 13)
        router.push(controller)
    }
}

extension InboxCoordinator: MessengerDelegate {
    func messengerDidLogin(userID: UInt64, success: Bool) {
        logger.debug(userID, success)
        start()
    }
    
    func messengerDidLogout(userID: UInt64) {
        logger.debug(userID)
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
