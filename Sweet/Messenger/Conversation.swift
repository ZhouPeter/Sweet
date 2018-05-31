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
    let timeText: String
    let localMessageID: String
    let content: String
    var avatarURLString: String?
}
