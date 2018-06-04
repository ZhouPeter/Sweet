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
    func messengerDidReceiveMessage(_ message: InstantMessage)
}

extension MessengerDelegate {
    func messengerDidLogin(user: User, success: Bool) {}
    func messengerDidLogout(user: User) {}
    func messengerDidUpdateState(_ state: MessengerState) {}
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {}
    func messengerDidUpdateServerDate(_ date: Date?) {}
    func messengerDidUpdateConversations(_ conversations: [Conversation]) {}
    func messengerDidReceiveMessage(_ message: InstantMessage) {}
}
