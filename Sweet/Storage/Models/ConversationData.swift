//
//  ConversationData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class ConversationData: Object {
    @objc dynamic var userID: Int64 = 0
    @objc dynamic var user: UserData?
    @objc dynamic var date = Date()
    @objc dynamic var unreadCount = 0
    @objc dynamic var likesCount = 0
    @objc dynamic var lastMessage: InstantMessageData?
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    class func data(with conversation: Conversation) {
        let data = ConversationData()
        data.userID = Int64(conversation.user.userId)
        data.user = UserData.data(with: conversation.user)
        data.unreadCount = conversation.unreadCount
        data.likesCount = conversation.likesCount
        if let message = conversation.lastMessage {
            data.lastMessage = InstantMessageData.data(with: message)
        }
        data.date = conversation.date
    }
}
