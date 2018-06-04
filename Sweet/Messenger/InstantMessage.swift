//
//  InstantMessage.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct InstantMessage {
    var localID = UUID().uuidString
    var remoteID: UInt64?
    var from: UInt64 = 0
    var fromName: String?
    var to: UInt64 = 0
    var type: IMType = .unknown
    var content: String = String()
    var status: UInt32 = 0
    var createDate = Date()
    var sentDate = Date()
    var isSent = false
    var isRead = false
    
    var displayText: String {
        switch type {
        case .text:
            return content
        default:
            return "[未知消息]"
        }
    }
    
    init() {}
    
    init(from: UInt64, to: UInt64, type: IMType) {
        self.init()
        self.from = from
        self.to = to
        self.type = type
    }
}

extension InstantMessage {
    func makeSendRequest() -> SendReq {
        var request = SendReq()
        request.type = type
        request.content = content
        request.sendTime = Date().timestamp()
        request.to = to
        return request
    }
}

extension InstantMessage {
    init(_ proto: IMProto) {
        remoteID = proto.id
        from = proto.from
        to = proto.to
        type = proto.type
        content = proto.content
        status = proto.status
        createDate = Date(timeIntervalSince1970: TimeInterval(proto.created) / 1000)
        sentDate =  Date(timeIntervalSince1970: TimeInterval(proto.sendTime) / 1000)
    }
    
    init(_ data: InstantMessageData) {
        localID = data.localID
        if let value = data.remoteID.value {
            remoteID = UInt64(value)
        }
        from = UInt64(data.from)
        fromName = data.fromName
        to = UInt64(data.to)
        type = IMType(rawValue: data.type) ?? .unknown
        content = data.content
        status = UInt32(data.status)
        createDate = data.createDate
        sentDate = data.sentDate
        isSent = data.isSent
        isRead = data.isRead
    }
}
