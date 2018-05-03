//
//  CardsCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol CardsView: BaseView {
    
}

final class CardsCoordinator: BaseCoordinator {
    private let factory: CardsFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    init(router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
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
        let cards = factory.makeCardsView()
        router.setRootFlow(cards)
    }
}
