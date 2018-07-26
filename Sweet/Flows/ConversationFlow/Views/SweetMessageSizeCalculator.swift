//
//  SweetMessageSizeCalculator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

final class SweetMessageSizeCalculator: MessageSizeCalculator {
    override init(layout: MessagesCollectionViewFlowLayout?) {
        super.init(layout: layout)
        incomingMessagePadding = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 30)
        outgoingMessagePadding = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 8)
    }
    
    override func messageContainerSize(for message: MessageType) -> CGSize {
        guard case let .custom(value) = message.kind else {
            return super.messageContainerSize(for: message)
        }
        let maxWidth = 200
        if value is StoryMessageContent || value is OptionCardContent || value is ContentCardContent ||
            value is ImageMessageContent {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        return super.messageContainerSize(for: message)
    }
}
