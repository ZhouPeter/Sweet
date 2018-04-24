//
//  IMCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol IMListView: BaseView {
    
}

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
        showIMList()
    }
    
    // MARK: - Private
    
    private func showIMList() {
        let list = IMListController()
        router.setRootFlow(list)
    }
}
