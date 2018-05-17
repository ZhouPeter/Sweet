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
        showStoryRecordView()
    }
    
    // MARK: - Private
    
    private func showStoryRecordView() {
        let controller = factory.makeStoryRecordView()
        controller.onRecorded = { [weak self] url, isPhoto in
            self?.showStoryEditView(with: url, isPhoto: isPhoto)
        }
        // Preload
        _ = controller.toPresent()?.view
        router.setRootFlow(controller)
    }
    
    private func showStoryEditView(with fileURL: URL, isPhoto: Bool) {
        let controller = factory.makeStoryEditView(fileURL: fileURL, isPhoto: isPhoto)
        controller.onCancelled = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        controller.onFinished = { [weak self] _ in
            self?.router.popFlow(animated: true)
        }
        router.push(controller)
    }
}
