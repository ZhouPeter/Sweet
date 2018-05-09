//
//  IMCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
final class IMCoordinator: BaseCoordinator {
    private let factory: IMFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    init(router: Router, factory: IMFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        logger.debug()
        showIMManager()
    }
    
    // MARK: - Private
    
    private func showIMManager() {
        let managerView = factory.makeIMManagerView()
        managerView.showIMList = { [weak self] iMListView in
            self?.showIMList(iMListView: iMListView)
        }
        managerView.showIMContacts = { [weak self] iMContactsView in
            self?.showIMContacts(iMContactsView: iMContactsView)
        }
        router.setRootFlow(managerView)
    }
    
    private func showIMList(iMListView: IMListView) {
        
    }
}

// MARK: - Contacts
extension IMCoordinator {
    private func showIMContacts(iMContactsView: IMContactsView) {
        iMContactsView.showProfile = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        
        iMContactsView.showInvite = { [weak self] in
            self?.showInvite()
        }
        
        iMContactsView.showBlack = { [weak self] in
            self?.showBlack()
        }
        iMContactsView.showBlock = { [weak self] in
            self?.showBlock()
        }
        iMContactsView.showSubscription = { [weak self] in
            self?.showSubscription()
        }
    }
    
    private func showProfile(userId: UInt64) {
        let profileView = factory.makeProfileOutput(userId: userId)
        router.push(profileView)
    }
    
    private func showInvite() {
        let inviteView = factory.makeInviteOutput()
        router.push(inviteView)
    }
    
    private func showBlack() {
        let blackView = factory.makeBlackOutput()
        blackView.showProfile = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        router.push(blackView)
    }
    private func showBlock() {
        let blockView = factory.makeBlockOutput()
        blockView.showProfile = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        router.push(blockView)
    }
    
    private func showSubscription() {
        let subscriptionView = factory.makeSubscriptionOutput()
        subscriptionView.showProfile = { [weak self] userId in
            self?.showProfile(userId: userId)
        }
        router.push(subscriptionView)
    }

}
