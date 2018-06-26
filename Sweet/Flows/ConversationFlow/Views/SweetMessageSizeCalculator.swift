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
    override func messageContainerSize(for message: MessageType) -> CGSize {
        guard case let .custom(value) = message.kind else {
            return super.messageContainerSize(for: message)
        }
        let maxWidth = 200
        if value is StoryMessageContent {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        if let content = value as? OptionCardContent {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        if let content = value as? ContentCardContent {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        return super.messageContainerSize(for: message)
    }
}
