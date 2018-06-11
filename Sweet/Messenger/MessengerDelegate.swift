//
//  MessengerDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol MessengerDelegate: class {
    func messengerDidLogin(user: User, success: Bool)
    func messengerDidLogout(user: User)
    func messengerDidUpdateState(_ state: MessengerState)
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool)
    func messengerDidUpdateServerDate(_ serverDate: Date?)
    func messengerDidUpdateConversations(_ conversations: [Conversation])
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User)
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], buddy: User)
    func messengerDidReceiveMessage(_ message: InstantMessage)
    func messengerDidUpdateUnreadCount(messageUnread: Int, likesUnread: Int)
}

extension MessengerDelegate {
    func messengerDidLogin(user: User, success: Bool) {}
    func messengerDidLogout(user: User) {}
    func messengerDidUpdateState(_ state: MessengerState) {}
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {}
    func messengerDidUpdateServerDate(_ date: Date?) {}
    func messengerDidUpdateConversations(_ conversations: [Conversation]) {}
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User) {}
    func messengerDidReceiveMessage(_ message: InstantMessage) {}
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], buddy: User) {}
    func messengerDidUpdateUnreadCount(messageUnread: Int, likesUnread: Int) {}
}
