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
    var cardType: CardType?
    var cardID: String?
    
    var displayText: String {
        switch type {
        case .text:
            return content
        case .story:
            return "你有一条小故事消息"
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
    
    mutating func set(cardType: CardType, cardID: String) {
        self.cardType = cardType
        self.cardID = cardID
        content = "{\"cardType\":\(cardType.rawValue),\"identifier\":\(cardID)}"
    }
    
    enum CardType: Int {
        case content = 1
        case preference
        case activity
        case evalutaion
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
    init(proto: IMProto) {
        remoteID = proto.id
        from = proto.from
        to = proto.to
        type = proto.type
        content = proto.content
        status = proto.status
        createDate = Date(timeIntervalSince1970: TimeInterval(proto.created) / 1000)
        sentDate =  Date(timeIntervalSince1970: TimeInterval(proto.sendTime) / 1000)
        parseCardContent()
    }
    
    init(data: InstantMessageData) {
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
        parseCardContent()
    }
    
    private mutating func parseCardContent() {
        guard
            let data = content.data(using: .utf8),
            let info = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
            let cardTypeValue = info?["card_type"] as? Int,
            let identifier = info?["identifier"] as? String
        else { return }
        cardID = identifier
        cardType = CardType(rawValue: cardTypeValue)
    }
}
