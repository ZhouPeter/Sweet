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
        return .text(content)
    }
}
