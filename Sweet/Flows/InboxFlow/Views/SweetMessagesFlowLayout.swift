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
    lazy var sizeCalculator = SweetMessageSizeCalculator(layout: self)
    
    override func cellSizeCalculatorForItem(at indexPath: IndexPath) -> CellSizeCalculator {
        let message = messagesDataSource.messageForItem(at: indexPath, in: messagesCollectionView)
        if case .custom = message.kind {
            return sizeCalculator
        }
        return super.cellSizeCalculatorForItem(at: indexPath)
    }
}
