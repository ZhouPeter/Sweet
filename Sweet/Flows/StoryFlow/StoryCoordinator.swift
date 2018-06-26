//
//  StoryCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

protocol StoryCoodinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

final class StoryCoordinator: BaseCoordinator, StoryCoodinatorOutput {
    var finishFlow: (() -> Void)?
    
    private let factory: StoryFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let isDismissable: Bool
    private let topic: String?
    
    init(user: User,
         router: Router,
         factory: StoryFlowFactory,
         coordinatorFactory: CoordinatorFactory,
         isDismissable: Bool = false,
         topic: String? = nil) {
        self.user = user
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
        self.topic = topic
        self.isDismissable = isDismissable
    }
    
    override func start() {
        logger.debug()
        showStoryRecordView()
    }
    
    // MARK: - Private
    
    private func showStoryRecordView() {
        let controller: StoryRecordView
        if isDismissable {
            controller = factory.makeDismissableStoryRecordView(user: user, topic: topic)
        } else {
            controller = factory.makeStoryRecordView(user: user)
        }
        controller.onRecorded = { [weak self] url, isPhoto, topic in
            self?.showStoryEditView(with: url, isPhoto: isPhoto, topic: topic)
        }
        controller.onTextChoosed = { [weak self] topic in
            self?.showStoryTextView(with: topic)
        }
        controller.onAlbumChoosed = { [weak self] topic in
            self?.showAlbumView(with: topic)
        }
        controller.onAvatarButtonPressed = { [weak self] in
            self?.showRecentStories()
        }
        if isDismissable {
            controller.onDismissed = { [weak self] in
                self?.dismiss()
            }
        }
        controller.prepare()
        router.setRootFlow(controller)
    }
    
    private func showStoryEditView(with fileURL: URL, isPhoto: Bool, topic: String?) {
        let controller = factory.makeStoryEditView(fileURL: fileURL, isPhoto: isPhoto, topic: topic)
        controller.onCancelled = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        controller.onFinished = { [weak self] _ in
            if self?.isDismissable == true {
                self?.dismiss()
            } else {
                self?.router.popFlow(animated: true)
            }
        }
        router.setAsSecondFlow(controller)
    }
    
    private func showStoryTextView(with topic: String?) {
        let controller = factory.makeStoryTextView(with: topic)
        controller.onFinished = { [weak self] in
            self?.router.popFlow(animated: true)
        }
        controller.onCancelled = { [weak self] in
            if self?.isDismissable == true {
                self?.dismiss()
            } else {
                self?.router.popFlow(animated: true)
            }
        }
        router.push(controller)
    }
    
    private func showAlbumView(with topic: String?) {
        let controller = factory.makeAlbumView()
        controller.onFinished = { [weak self] image in
            self?.showPhotoCropView(with: image, topic: topic)
        }
        router.push(controller)
    }
    
    private func showPhotoCropView(with image: UIImage, topic: String?) {
        let controller = factory.makePhotoCropView(with: image)
        controller.onFinished = { [weak self] url in
            self?.showStoryEditView(with: url, isPhoto: true, topic: topic)
        }
        router.push(controller)
    }
    
    private func showRecentStories() {
        web.request(
            .storyList(page: 0, userId: user.userId),
            responseType: Response<StoryListResponse>.self) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    logger.error(error)
                case .success(let response):
                    Defaults[.isPersonalStoryChecked] = true
//                    let viewModels = response.list.map(StoryCellViewModel.init(model:))
//                    let storiesPlayViewController = StoriesPlayerViewController(user: self.user)
//                    storiesPlayViewController.stories = viewModels
//                    self.present(storiesPlayViewController, animated: true) {
//                        storiesPlayViewController.initPlayer()
//                    }
                }
        }
    }

    private func dismiss() {
        router.dismissFlow(animated: true, completion: {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
            NotificationCenter.default.post(name: .EnablePageScroll, object: nil)
        })
        finishFlow?()
    }
}
