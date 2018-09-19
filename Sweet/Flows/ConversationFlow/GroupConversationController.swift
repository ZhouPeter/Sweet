//
//  GroupConversationController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/19.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

protocol GroupConversationView: BaseView {
    
}

final class GroupConversationController: ConversationViewController, GroupConversationView {
    private let conversation: IMConversation
    
    init(user: User, conversation: IMConversation) {
        self.conversation = conversation
        super.init(user: user)
        Messenger.shared.addDelegate(self)
//        Messenger.shared.loadMessages(from: <#T##User#>)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = conversation.name
        messageInputBar.delegate = self
    }
}

extension GroupConversationController: MessageInputBarDelegate {
    
}

extension GroupConversationController: MessengerDelegate {
    
}
