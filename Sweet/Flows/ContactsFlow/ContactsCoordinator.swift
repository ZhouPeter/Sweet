//
//  ContactsCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

final class ContactsCoordinator: BaseCoordinator {
    private let factory: ContactsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let token: String
    private let storage: Storage
    
    init(token: String,
         storage: Storage,
         router: Router,
         factory: ContactsFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
        self.router = router
        self.token = token
        self.storage = storage
    }
    
    func start(with view: ContactsView) {
        view.delegate = self
    }
}

extension ContactsCoordinator: ContactsViewDelegate {
    func contactsShowSubscription() {
        let subscriptionView = factory.makeSubscriptionOutput()
        subscriptionView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(subscriptionView)
    }
    
    func contactsShowInvite() {
        let inviteView = factory.makeInviteOutput()
        router.push(inviteView)
    }
    
    func contactsShowBlock() {
        let blockView = factory.makeBlockOutput()
        blockView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(blockView)
    }
    
    func contactsShowProfile(userID: UInt64) {
        showProfile(userID: userID)
    }
    
    func contactsShowBlack() {
        let blackView = factory.makeBlackOutput()
        blackView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(blackView)
    }
    
    private func showProfile(userID: UInt64) {
        let profileView = factory.makeProfileOutput(userId: userID)
        router.push(profileView)
    }
}
