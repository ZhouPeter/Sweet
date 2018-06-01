//
//  Conversation.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct Conversation {
    let userID: UInt64
    let username: String
    let date: Date
    let unreadCount: Int
    var lastMessageID: String?
    var avatarURLString: String?
    var content: String?
    
    init(userID: UInt64, username: String, date: Date, unreadCount: Int = 0) {
        self.userID = userID
        self.username = username
        self.date = date
        self.unreadCount = unreadCount
    }
}
