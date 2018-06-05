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
        case .story:
            return .custom(CustomMessageKind.story)
        case .card:
            if content is ContentCardContent {
                return .custom(CustomMessageKind.evaluationCard)
            }
            if let content = content as? OptionCardContent {
                if content.cardType == .evalutaion {
                    return .custom(CustomMessageKind.evaluationCard)
                }
                return .custom(CustomMessageKind.preferenceCard)
            }
            if content is StoryMessageContent {
                return .custom(CustomMessageKind.story)
            }
            return .text("[不支持该消息类型]")
        case .text:
            return .text(rawContent)
        default:
            return .text("[不支持该消息类型]")
        }
    }
}

enum CustomMessageKind {
    case story
    case contentCard
    case preferenceCard
    case evaluationCard
}
