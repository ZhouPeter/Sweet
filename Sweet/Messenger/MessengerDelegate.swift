//
//  MessengerDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol MessengerDelegate: class {
    func messengerDidLogin(userID: UInt64, success: Bool)
    func messengerDidLogout(userID: UInt64)
    func messengerDidUpdateState(_ state: MessengerState)
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool)
    func messengerDidUpdateServerDate(_ serverDate: Date?)
    func messengerDidUpdateConversations(_ conversations: [Conversation])
}

extension MessengerDelegate {
    func messengerDidLogin(userID: UInt64, success: Bool) {}
    func messengerDidLogout(userID: UInt64) {}
    func messengerDidUpdateState(_ state: MessengerState) {}
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {}
    func messengerDidUpdateServerDate(_ date: Date?) {}
    func messengerDidUpdateConversations(_ conversations: [Conversation]) {}
}
