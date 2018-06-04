//
//  Conversation.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct Conversation {
    let user: User
    let date: Date
    var lastMessage: InstantMessage?
    let unreadCount: Int
    
    init(user: User, date: Date, unreadCount: Int = 0) {
        self.user = user
        self.date = date
        self.unreadCount = unreadCount
    }
    
    init?(data: ConversationData) {
        guard let userData = data.user else { return nil }
        user = User.init(data: userData)
        unreadCount = data.unreadCount
        if let messageData = data.lastMessage {
            lastMessage = InstantMessage(data: messageData)
        }
        date = data.date
    }
}
