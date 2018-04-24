//
//  StoryCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

final class StoryCoordinator: BaseCoordinator {
    private let factory: StoryFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    init(router: Router, factory: StoryFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        logger.debug()
        showStoryRecord()
    }
    
    // MARK: - Private
    
    private func showStoryRecord() {
        let controller = factory.makeStoryRecordView()
        router.setRootFlow(controller)
    }
}
