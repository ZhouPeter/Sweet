//
//  ConversationData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class ConversationData: Object {
    @objc dynamic var key = ""
    @objc dynamic var id: Int64 = 0
    @objc dynamic var name = ""
    @objc dynamic var memberCount = 0
    let memberIDs = List<Int64>()
    @objc dynamic var avatarURL = ""
    @objc dynamic var isGroup = false
    let lastMessageID = RealmOptional<Int64>()
    @objc dynamic var lastMessageContent = ""
    let lastMessageTimestamp = RealmOptional<Int64>()
    @objc dynamic var unreadCount = 0
    @objc dynamic var likesCount = 0
    @objc dynamic var isMute = false
    
    override static func primaryKey() -> String? {
        return "key"
    }
    
    class func data(with conversation: IMConversation) -> ConversationData {
        let data = ConversationData()
        data.id = Int64(conversation.id)
        data.name = conversation.name
        data.memberCount = Int(conversation.memberCount)
        data.memberIDs.append(objectsIn: conversation.memberIds.map(Int64.init))
        data.avatarURL = conversation.avatarURL
        data.isGroup = conversation.isGroup
        if conversation.lastMessageID > 0 {
            data.lastMessageID.value = Int64(conversation.lastMessageID)
            data.lastMessageContent = conversation.lastMessageContent
            data.lastMessageTimestamp.value = Int64(conversation.lastMessageTimestamp)
        }
        data.unreadCount = Int(conversation.unreadCount)
        data.likesCount = Int(conversation.likeCount)
        data.isMute = conversation.isMute
        data.key = ConversationData.makeKey(id: conversation.id, isGroup: conversation.isGroup)
        return data
    }
    
    class func makeKey(id: UInt64, isGroup: Bool) -> String {
        return "\(id)#\(isGroup)"
    }
    
    func makeIMConversation() -> IMConversation {
        var conversation = IMConversation()
        conversation.id = UInt64(id)
        conversation.name = name
        conversation.memberIds = memberIDs.map(UInt64.init)
        conversation.memberCount = UInt32(memberCount)
        conversation.avatarURL = avatarURL
        conversation.isGroup = isGroup
        if let id = lastMessageID.value {
            conversation.lastMessageID = UInt64(id)
        }
        conversation.lastMessageContent = lastMessageContent
        if let timestamp = lastMessageTimestamp.value, timestamp > 0 {
            conversation.lastMessageTimestamp = UInt64(timestamp)
        }
        conversation.unreadCount = UInt64(unreadCount)
        conversation.likeCount = UInt64(likesCount)
        conversation.isMute = isMute
        return conversation
    }
}
