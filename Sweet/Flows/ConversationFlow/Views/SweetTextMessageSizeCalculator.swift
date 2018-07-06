//
//  SweetTextMessageSizeCalculator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import MessageKit

final class SweetTextMessageSizeCalculator: TextMessageSizeCalculator {
    override init(layout: MessagesCollectionViewFlowLayout?) {
        super.init(layout: layout)
        incomingMessagePadding = UIEdgeInsets(top: 10, left: 8, bottom: 0, right: 30)
        outgoingMessagePadding = UIEdgeInsets(top: 10, left: 30, bottom: 0, right: 8)
    }
    
    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        return 200
    }
}
