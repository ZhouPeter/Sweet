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
    private let user: User
    
    init(user: User, router: Router, factory: StoryFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.user = user
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
        let controller = factory.makeStoryRecordView(user: user)
        controller.onRecorded = { [weak self] url, isPhoto, topic in
            self?.showStoryEditView(with: url, isPhoto: isPhoto, topic: topic)
        }
        controller.onTextChoosed = { [weak self] in
            self?.showStoryTextView()
        }
        controller.onAlbumChoosed = { [weak self] in
            self?.showAlbumView()
        }
        // Preload
        _ = controller.toPresent()?.view
        router.setRootFlow(controller)
    }
    
    private func showStoryEditView(with fileURL: URL, isPhoto: Bool, topic: String?) {
        let controller = factory.makeStoryEditView(fileURL: fileURL, isPhoto: isPhoto, topic: topic)
        controller.onCancelled = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        controller.onFinished = { [weak self] _ in
            self?.router.popFlow(animated: true)
        }
        router.setAsSecondFlow(controller)
    }
    
    private func showStoryTextView() {
        let controller = factory.makeStoryTextView()
        controller.onFinished = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        controller.onCancelled = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        router.push(controller)
    }
    
    private func showAlbumView() {
        let controller = factory.makeAlbumView()
        controller.onFinished = { [weak self] image in
            self?.showPhotoCropView(with: image)
        }
        router.push(controller)
    }
    
    private func showPhotoCropView(with image: UIImage) {
        let controller = factory.makePhotoCropView(with: image)
        controller.onFinished = { [weak self] url in
            self?.showStoryEditView(with: url, isPhoto: true, topic: nil)
        }
        router.push(controller)
    }
}
