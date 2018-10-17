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
    func messengerDidUpdateConversations(_ conversations: [IMConversation])
    func messengerDidReceiveMessage(_ message: InstantMessage)
    func messengerDidUpdateUnreadCount(messageUnread: Int, likesUnread: Int)
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User)
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], buddy: User)
    func messengerDidLoadMessages(_ messages: [InstantMessage], group: Group)
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], group: Group)
    func messengerDidUpdateMember(_ member: User)
    func messengerDidQuitGroup(_ groupID: UInt64, success: Bool)
    func messengerDidMuteGroup(_ groupID: UInt64, isMuted: Bool)
    func messengerDidBeginFetchMessages(group: Group)
    func messengerDidFetchMessages(group: Group)
    func messengerDidBeginFetchMessages(buddy: User)
    func messengerDidFetchMessages(buddy: User)
}

extension MessengerDelegate {
    func messengerDidLogin(user: User, success: Bool) {}
    func messengerDidLogout(user: User) {}
    func messengerDidUpdateState(_ state: MessengerState) {}
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {}
    func messengerDidUpdateServerDate(_ date: Date?) {}
    func messengerDidUpdateConversations(_ conversations: [IMConversation]) {}
    func messengerDidReceiveMessage(_ message: InstantMessage) {}
    func messengerDidUpdateUnreadCount(messageUnread: Int, likesUnread: Int) {}
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User) {}
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], buddy: User) {}
    func messengerDidLoadMessages(_ messages: [InstantMessage], group: Group) {}
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], group: Group) {}
    func messengerDidUpdateMember(_ member: User) {}
    func messengerDidQuitGroup(_ groupID: UInt64, success: Bool) {}
    func messengerDidMuteGroup(_ groupID: UInt64, isMuted: Bool) {}
    func messengerDidBeginFetchMessages(group: Group) {}
    func messengerDidFetchMessages(group: Group) {}
    func messengerDidBeginFetchMessages(buddy: User) {}
    func messengerDidFetchMessages(buddy: User) {}
}
