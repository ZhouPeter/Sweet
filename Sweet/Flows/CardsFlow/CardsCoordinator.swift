//
//  CardsCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


final class CardsCoordinator: BaseCoordinator {
    private let factory: CardsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    
    init(user: User, router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        logger.debug()
        showCards()
    }
    
    // MARK: - Private
    
    private func showCards() {
        let cards = factory.makeCardsManagerView(user: user)
        router.setRootFlow(cards)
    }
}
