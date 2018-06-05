//
//  SweetMessagesFlowLayout.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

final class SweetMessagesFlowLayout: MessagesCollectionViewFlowLayout {
    private lazy var storySizeCalculator = StoryMessageSizeCalculator(layout: self)
    
    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case let .custom(value) = message.kind, let kind = value as? CustomMessageKind {
            switch kind {
            case .story:
                return storySizeCalculator
            default:
                break
            }
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
}
