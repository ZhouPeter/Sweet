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
    var rawContent = ""
    var status: UInt32 = 0
    var createDate = Date()
    var sentDate = Date()
    var isSent = false
    var isRead = false
    var isFailed = false
    var isSending = false
    var extra: String?
    var content: MessageContent? {
        didSet {
            guard let content = content else {
                rawContent = ""
                return
            }
            rawContent = content.encoded()
        }
    }
    
    func displayText() -> String {
        switch type {
        case .text:
            return rawContent
        case .story:
            return  "[小故事]"
        case .card, .article :
            return  "[分享]"
        case .like:
            return "[赞]"
        case .image:
            return "[图片]"
        default:
            return "[未知消息]"
        }
    }
    
    init() {}
    
    init(from: UInt64, to: UInt64, type: IMType, extra: String? = nil) {
        self.init()
        self.from = from
        self.to = to
        self.type = type
        self.extra = extra
    }
    
    enum CardType: Int, Codable {
        case unknown
        case content
        case preference
        case evaluation
    }
}

extension InstantMessage {
    func makeSendRequest() -> SendReq {
        var request = SendReq()
        request.type = type
        request.content = rawContent
        request.sendTime = Date().timestamp()
        request.to = to
        if let extra = self.extra {
            request.extra = extra
        }
        return request
    }
}

extension InstantMessage {
    init(proto: IMProto) {
        remoteID = proto.id
        from = proto.from
        to = proto.to
        type = proto.type
        rawContent = proto.content
        status = proto.status
        createDate = Date(timeIntervalSince1970: TimeInterval(proto.created) / 1000)
        sentDate =  Date(timeIntervalSince1970: TimeInterval(proto.sendTime) / 1000)
        extra = proto.extra.isEmpty ? nil : proto.extra
        parseContent()
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
        rawContent = data.content
        status = UInt32(data.status)
        createDate = data.createDate
        sentDate = data.sentDate
        isSent = data.isSent
        isRead = data.isRead
        isFailed = !data.isSent
        extra = data.extra
        parseContent()
    }
    
    mutating func parseContent() {
        guard
            let data = rawContent.data(using: .utf8),
            let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
        else {
            return
        }
        if type == .image {
            parseContent(ImageMessageContent.self, data: data)
        } else if type == .article {
            parseContent(ArticleMessageContent.self, data: data)
        } else if type == .story {
            parseContent(StoryMessageContent.self, data: data)
        } else if type == .card {
            guard let contentType = json?["type"] as? Int, let cardType = CardType(rawValue: contentType) else {
                logger.error("Parse faild: \(rawContent)")
                return
            }
            switch cardType {
            case .content:
                parseContent(ContentCardContent.self, data: data)
            case .evaluation, .preference:
                parseContent(OptionCardContent.self, data: data)
            default:
                logger.error("unsupported card type: \(cardType)")
            }
        }
    }
    
    mutating func parseContent<T>(_ contentType: T.Type, data: Data) where T: MessageContent {
        do {
            content = try JSONDecoder().decode(T.self, from: data)
        } catch {
            logger.error("\(error) for \(contentType)")
        }
    }
}
