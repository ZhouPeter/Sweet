//
//  InstantMessage.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct InstantMessage {
    var localID = UUID()
    var remoteID: UInt64 = 0
    var from: UInt64 = 0
    var to: UInt64 = 0
    var type: IMType = .unknown
    var content: String = String()
    var status: UInt32 = 0
    var createDate = Date()
    var sentDate: Date?
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
}
