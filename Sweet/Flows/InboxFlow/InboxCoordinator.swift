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
    private var conversations = [IMConversation]()
    private var inboxView: InboxView?
    
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
    
    private var isLocalConversationsLoaded = false
    
    override func start() {
        if !isLocalConversationsLoaded {
            isLocalConversationsLoaded = true
            Messenger.shared.loadLocalConversations()
        }
    }
}

extension InboxCoordinator: InboxViewDelegate {
    func inboxRemoveConversation(_ conversation: IMConversation) {
        Messenger.shared.removeConversation(conversation)
    }
    
    func inboxStartConversation(_ conversation: IMConversation) {
        if conversation.isGroup {
            Messenger.shared.loadGroupWith(id: conversation.id) { [weak self] (group) in
                guard let group = group else {
                    logger.error("Group is nil")
                    return
                }
                self?.startConversationWith(group: group, conversation: conversation)
            }
        } else {
            Messenger.shared.loadUserWith(id: conversation.id) { [weak self] (user) in
                guard let user = user else {
                    logger.error("User is nil")
                    return
                }
                self?.startConversationWith(buddy: user, conversation: conversation)
            }
        }
    }
    
    private func startConversationWith(buddy: User, conversation: IMConversation) {
        let coordinator = SingleConversationCoordinator(user: user,
                                                        buddy: buddy,
                                                        conversation: conversation,
                                                        router: router,
                                                        coordinatorFactory: coordinatorFactory)
        coordinator.finishFlow = { [weak self] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func startConversationWith(group: Group, conversation: IMConversation) {
        let coordinator = GroupConversationCoordinator(user: user,
                                                       group: group,
                                                       conversation: conversation,
                                                       router: router,
                                                       coordinatorFactory: coordinatorFactory)
        coordinator.finishFlow = { [weak self] in self?.removeDependency(coordinator) }
        addDependency(coordinator)
        coordinator.start()
    }
}

extension InboxCoordinator: MessengerDelegate {
    func messengerDidLogin(user: User, success: Bool) {
        logger.debug("\(user.nickname), success: \(success)")
        Messenger.shared.loadConversations()
        self.inboxView?.didUpdateUserOnlineState(isUserOnline: true)
    }
    
    func messengerDidLogout(user: User) {
        logger.debug(user.nickname)
        self.inboxView?.didUpdateUserOnlineState(isUserOnline: false)
    }
    
    func messengerDidUpdateState(_ state: MessengerState) {
        logger.debug(state)
        self.inboxView?.didUpdateUserOnlineState(isUserOnline: state == .online)
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        logger.debug("\(message.rawContent), success: \(success)")
    }
    
    func messengerDidUpdateConversations(_ conversations: [IMConversation]) {
        inboxView?.didUpdateConversations(conversations)
    }
}
