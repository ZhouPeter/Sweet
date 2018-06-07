//
//  Messenger+Send.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension Messenger {
    @discardableResult func sendText(_ text: String, from: UInt64, to: UInt64, extra: String? = nil) -> InstantMessage {
        var message = InstantMessage(from: from, to: to, type: .text, extra: extra)
        message.rawContent = text
        send(message)
        return message
    }
    
    @discardableResult func sendStory(_ content: StoryMessageContent,
                                      from: UInt64,
                                      to: UInt64,
                                      extra: String? = nil) -> InstantMessage {
        return sendMessage(with: content, type: .story, from: from, to: to, extra: extra)
    }
    
    @discardableResult func sendEvaluationCard(
        _ content: OptionCardContent,
        from: UInt64,
        to: UInt64,
        extra: String? = nil) -> InstantMessage {
        return sendMessage(with: content, type: .card, from: from, to: to, extra: extra)
    }
    
    @discardableResult func sendPreferenceCard(
        _ content: OptionCardContent,
        from: UInt64,
        to: UInt64,
        extra: String? = nil) -> InstantMessage {
        return sendMessage(with: content, type: .card, from: from, to: to)
    }
    
    @discardableResult func sendContentCard(_ content: ContentCardContent,
                                            from: UInt64,
                                            to: UInt64,
                                            extra: String? = nil) -> InstantMessage {
        return sendMessage(with: content, type: .card, from: from, to: to, extra: extra)
    }
    
    @discardableResult func sendLike(from: UInt64, to: UInt64, extra: String? = nil) -> InstantMessage {
        return sendMessage(type: .like, from: from, to: to, extra: extra)
    }
    
    @discardableResult func sendMessage(
        with content: MessageContent? = nil,
        type: IMType,
        from: UInt64,
        to: UInt64,
        extra: String? = nil) -> InstantMessage {
        var message = InstantMessage(from: from, to: to, type: type, extra: extra)
        message.content = content
        send(message)
        return message
    }
}
