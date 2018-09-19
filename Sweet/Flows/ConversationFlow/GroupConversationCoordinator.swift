//
//  GroupConversationCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/19.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation

struct Group {
    let id: UInt64
    var name: String
    var memberCount: Int
    var avatarURL: String
}

protocol GroupConversationCoordinatorOutput {
    var finishFlow: (() -> Void)? { get set }
}

final class GroupConversationCoordinator: BaseCoordinator, ConversationCoordinatorOuput {
    var finishFlow: (() -> Void)?
    
    private let user: User
    private let group: Group
    private let router: Router
    private let coordinatorFactory: CoordinatorFactory
    private let storage: Storage
    
    init(user: User, group: Group, router: Router, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.group = group
        self.router = router
        self.coordinatorFactory = coordinatorFactory
        self.storage = Storage(userID: user.userId)
    }
    
    override func start() {
        Messenger.shared.markConversationAsRead(group.id)
        
    }
}
