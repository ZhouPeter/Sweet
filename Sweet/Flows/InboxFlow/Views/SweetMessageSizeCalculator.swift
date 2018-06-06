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
        let maxWidth = messageContainerMaxWidth(for: message) * 0.8
        if value is StoryMessageContent {
            return CGSize(width: maxWidth, height: maxWidth)
        }
        if let content = value as? OptionCardContent {
            let boxSize = CGSize(width: maxWidth - 10 * 2, height: CGFloat.greatestFiniteMagnitude)
            let textSize = content.text.boundingSize(font: UIFont.preferredFont(forTextStyle: .body), size: boxSize)
            let size = CGSize(width: maxWidth, height: textSize.height + 6 * 2 + 140)
            return size
        }
        return super.messageContainerSize(for: message)
    }
}
