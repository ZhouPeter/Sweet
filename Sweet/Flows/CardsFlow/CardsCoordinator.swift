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
    private var allCoordinator: AllCardsCoordinator?
    private var subCoordinator: SubCardsCoordinator?
    init(user: User, router: Router, factory: CardsFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        showCards()
    }
    
    // MARK: - Private
    
    private func showCards() {
        let cards = factory.makeCardsManagerView(user: user)
        cards.delegate = self
        router.setRootFlow(cards)
    }

}

extension CardsCoordinator: CardsManagerViewDelegate {
    func showAll(view: CardsAllView) {
        guard allCoordinator == nil else { return }
        let coordinator = coordinatorFactory.makeAllCardsCoordinator(user: user, router: router)
        coordinator.start(with: view)
        allCoordinator = coordinator
    }
    
    func showSubscription(view: CardsSubscriptionView) {
        guard subCoordinator == nil else { return }
        let coordinator = coordinatorFactory.makeSubCardsCoordinator(user: user, router: router)
        coordinator.start(with: view)
        subCoordinator = coordinator
    }

}
