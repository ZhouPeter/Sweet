//
//  ConversationData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class ConversationData: Object {
    @objc dynamic var user: UserData?
    @objc dynamic var date = Date()
    @objc dynamic var unreadCount = 0
    @objc dynamic var lastMessage: InstantMessageData?
    
    class func data(with conversation: Conversation) {
        let data = ConversationData()
        data.user = UserData.data(with: conversation.user)
        data.unreadCount = conversation.unreadCount
        if let message = conversation.lastMessage {
            data.lastMessage = InstantMessageData.data(with: message)
        }
        data.date = conversation.date
    }
}
