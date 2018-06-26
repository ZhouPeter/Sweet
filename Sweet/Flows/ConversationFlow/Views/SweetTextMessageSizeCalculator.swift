//
//  SweetTextMessageSizeCalculator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import MessageKit

final class SweetTextMessageSizeCalculator: TextMessageSizeCalculator {
    override func messageContainerMaxWidth(for message: MessageType) -> CGFloat {
        return 200
    }
}
