//
//  InboxView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol InboxView: BaseView {
    var delegate: InboxViewDelegate? { get set }
    
    func didUpdateConversations(_ conversations: [Conversation])
    func didUpdateUserOnlineState(isUserOnline: Bool)
}

protocol InboxViewDelegate: class {
    func inboxRemoveConversation(_ conversation: Conversation)
    func inboxStartConversation(_ conversation: Conversation)
}
