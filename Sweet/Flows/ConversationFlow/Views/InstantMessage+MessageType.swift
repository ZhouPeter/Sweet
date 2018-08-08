//
//  InstantMessage+MessageType.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/1.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

extension InstantMessage: MessageType {
    var messageId: String {
        return localID
    }
    
    var sender: Sender {
        return Sender(id: "\(from)", displayName: fromName ?? "")
    }
    
    var kind: MessageKind {
        switch type {
        case .story, .card, .image, .article:
            if let content = content {
                return .custom(content)
            }
            return .text("[不支持该消息类型]")
        case .text:
            return .text(rawContent)
        case .like:
            return .text("❤️")
        default:
            return .text("[不支持该消息类型]")
        }
    }
}
