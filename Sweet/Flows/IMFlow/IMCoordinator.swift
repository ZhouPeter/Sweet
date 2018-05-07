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
    
    private func showIMContacts(iMContactsView: IMContactsView) {
        iMContactsView.showProfile = { userId in
            
        }
        
        iMContactsView.showInvite = { [weak self] in
            self?.showInvite()
        }
    }
    
    private func showInvite() {
        let inviteView = factory.makeInviteOutput()
        router.push(inviteView)
    }
    
}
