//
//  InstantMessageData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class InstantMessageData: Object {
    @objc dynamic var localID: String = ""
    let remoteID = RealmOptional<Int64>()
    @objc dynamic var from: Int64 = 0
    @objc dynamic var fromName: String?
    @objc dynamic var to: Int64 = 0
    @objc dynamic var type: Int = 0
    @objc dynamic var content: String = ""
    @objc dynamic var status: Int32 = 0
    @objc dynamic var createDate = Date()
    @objc dynamic var sentDate = Date()
    @objc dynamic var isSent = false
    @objc dynamic var isRead = false
    @objc dynamic var extra: String?
    
    override static func primaryKey() -> String? {
        return "localID"
    }
    
    class func data(with message: InstantMessage) -> InstantMessageData {
        let data = InstantMessageData()
        data.localID = message.localID
        if let remoteID = message.remoteID {
            data.remoteID.value = Int64(remoteID)
        }
        data.from = Int64(message.from)
        data.to = Int64(message.to)
        data.type = message.type.rawValue
        data.content = message.rawContent
        data.status = Int32(message.status)
        data.createDate = message.createDate
        data.sentDate = message.sentDate
        data.fromName = message.fromName
        data.isSent = message.isSent
        data.isRead = message.isRead
        data.extra = message.extra
        return data
    }
}
