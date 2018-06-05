//
//  StoryMessageSizeCalculator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

final class StoryMessageSizeCalculator: MessageSizeCalculator {
    override func messageContainerSize(for message: MessageType) -> CGSize {
        if case let .custom(value) = message.kind, let kind = value as? CustomMessageKind {
            switch kind {
            case .story:
                return CGSize(width: 200, height: 200)
            default:
                break
            }
        }
        return super.messageContainerSize(for: message)
    }
}
