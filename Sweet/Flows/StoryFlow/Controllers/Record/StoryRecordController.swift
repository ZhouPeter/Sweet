//
//  StoryRecordController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Hero

final class StoryRecordController: BaseViewController, StoryRecordView {
    var onRecorded: ((URL, Bool, String?) -> Void)?
    var onTextChoosed: (() -> Void)?
    var onAlbumChoosed: (() -> Void)?
    
    private let recordContainer = UIView()
    private let topView = StoryRecordTopView()
    private let bottomView = StoryRecordBottomView()
    private var captureView = StoryCaptureView()
    private var blurCoverView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    private lazy var textGradientController: TextGradientController = {
        let controller = TextGradientController()
        controller.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapTextGradientView))
        )
        return controller
    } ()
    
    private var enablePageScroll: Bool = true {
        didSet {
            NotificationCenter.default.post(
                name: enablePageScroll ? .EnablePageScroll : .DisablePageScroll,
                object: nil
            )
        }
    }
    private var topic: String? {
        didSet {
            topicButton.updateTopic(topic ?? "添加标签")
        }
    }
    private var shootButton = ShootButton()
    
    private lazy var topicButton: UIButton = {
        let button = UIButton(topic: "添加标签")
        button.addTarget(self, action: #selector(didPressTopicButton), for: .touchUpInside)
        return button
    } ()
    
    private var current = StoryRecordType.record
    private let user: User
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(recordContainer)
        recordContainer.backgroundColor = .clear
        recordContainer.fill(in: view)
        setupCaptureView()
        setupTopView()
        setupShootButton()
        setupBottomView()
        setupCoverView()
        checkAuthorized()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setupNavigation()
        if blurCoverView.isHidden == false {
            resumeCamera(true)
        } else if captureView.isStarted == false {
            captureView.startCaputre()
        }
        if current == .record && captureView.isPaused {
            captureView.resumeCamera()
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.topView.alpha = 1
            self.bottomView.alpha = 1
            self.topicButton.alpha = 1
        }, completion: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resumeCamera(false)
    }
    
    // MARK: - Private
    
    @objc private func didTapTextGradientView() {
        enablePageScroll = false
        onTextChoosed?()
    }

    private func edit(with url: URL, isPhoto: Bool) {
        enablePageScroll = false
        onRecorded?(url, isPhoto, topic)
    }
    
    @objc private func didPressTopicButton() {
        let topic = TopicListController()
        addChildViewController(topic)
        topic.didMove(toParentViewController: self)
        view.addSubview(topic.view)
        topic.view.frame = view.bounds
        topic.view.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            topic.view.alpha = 1
            self.topView.alpha = 0
            self.bottomView.alpha = 0
            self.shootButton.alpha = 0
            self.topicButton.alpha = 0
        }, completion: nil)
        topic.onFinished = { [weak self] topic in
            guard let `self` = self, let view = self.view.snapshotView(afterScreenUpdates: false) else { return }
            self.topic = topic
            self.view.addSubview(view)
            view.frame = self.view.bounds
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 0
                self.topView.alpha = 1
                self.bottomView.alpha = 1
                self.shootButton.alpha = 1
                self.topicButton.alpha = 1
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
    }
    
    // MARK: - Camera
    
    private func shootDidBegin() {
        UIView.animate(withDuration: 0.25) {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
            self.topicButton.alpha = 0
        }
        captureView.startRecording()
    }
    
    private func shootDidEnd(with interval: TimeInterval) {
        if interval < 1 {
            captureView.capturePhoto { [weak self] (url) in
                if let url = url {
                    self?.edit(with: url, isPhoto: true)
                }
            }
        } else {
            captureView.finishRecording { [weak self] (url) in
                if let url = url {
                    self?.edit(with: url, isPhoto: false)
                }
            }
        }
    }
    
    private func checkAuthorized() {
        let cameraAuthorization = TLAuthorizedManager.checkAuthorization(with: .camera)
        let micAuthorization = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        if cameraAuthorization && micAuthorization {
            if cameraAuthorization {
                startCamera()
            }
            if micAuthorization {
                captureView.enableAudio()
            }
        } else {
            let authorizedVC = TLStoryAuthorizationController()
            authorizedVC.delegate = self
            add(childViewController: authorizedVC)
        }
    }
    
    private func startCamera() {
        captureView.setupCamera()
        captureView.startCaputre()
    }
    
    private func resumeCamera(_ isOpen: Bool) {
        if isOpen {
            captureView.startCaputre()
        } else {
            captureView.stopCapture()
        }
        if isOpen {
            UIView.animate(withDuration: 0.25, delay: 0.25, options: [.curveEaseOut], animations: {
                self.blurCoverView.alpha = 0
            }, completion: { _ in
                self.blurCoverView.isHidden = true
            })
        } else {
            blurCoverView.alpha = 1
            blurCoverView.isHidden = false
        }
    }
    
    // MARK: - UI
    
    private func setupNavigation() {
        navigationController?.navigationBar.isHidden = true
        navigationController?.hero.isEnabled = true
        navigationController?.hero.navigationAnimationType = .fade
    }
    
    private func setupBottomView() {
        view.addSubview(bottomView)
        bottomView.align(.bottom, to: view)
        bottomView.align(.left, to: view)
        bottomView.align(.right, to: view)
        bottomView.constrain(height: 64)
        bottomView.delegate = self
    }
    
    private func setupShootButton() {
        recordContainer.addSubview(shootButton)
        shootButton.centerX(to: recordContainer)
        shootButton.constrain(width: 90, height: 90)
        shootButton.align(.bottom, to: view, inset: 64)
        shootButton.trackingDidStart = { [weak self] in self?.shootDidBegin() }
        shootButton.trackingDidEnd = { [weak self] interval in self?.shootDidEnd(with: interval) }
        
        recordContainer.addSubview(topicButton)
        topicButton.constrain(height: 30)
        topicButton.pin(.top, to: shootButton, spacing: 20)
        topicButton.centerX(to: recordContainer)
    }
    
    private func setupCaptureView() {
        recordContainer.addSubview(captureView)
        captureView.fill(in: recordContainer)
    }
    
    private func setupCoverView() {
        view.addSubview(blurCoverView)
        blurCoverView.isUserInteractionEnabled = true
        blurCoverView.fill(in: view)
    }
    
    private func setupTopView() {
        recordContainer.addSubview(topView)
        topView.delegate = self
        topView.constrain(height: 64)
        topView.align(.top, to: recordContainer)
        topView.align(.left, to: recordContainer)
        topView.align(.right, to: recordContainer)
    }
}

extension StoryRecordController: TLStoryAuthorizedDelegate {
    func requestMicAuthorizeSuccess() {
        captureView.enableAudio()
    }
    
    func requestCameraAuthorizeSuccess() {
        startCamera()
    }
    
    func requestAllAuthorizeSuccess() {}
}

extension StoryRecordController: StoryRecordBottomViewDelegate {
    func bottomViewDidPressTypeButton(_ type: StoryRecordType) {
        if type == .album {
            onAlbumChoosed?()
            bottomView.selectBottomButton(at: current.rawValue, animated: true)
            let last = current
            if current == .record {
                captureView.pauseCamera()
            }
            switchStoryType(type)
            current = last
        } else {
            switchStoryType(type)
        }
    }
    
    private func switchStoryType(_ type: StoryRecordType) {
        current = type
        if type == .text {
            if textGradientController.view.superview == nil {
                addChildViewController(textGradientController)
                textGradientController.didMove(toParentViewController: self)
                view.insertSubview(textGradientController.view, belowSubview: bottomView)
                textGradientController.view.fill(in: view)
            }
            textGradientController.view.alpha = 0
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.textGradientController.view.alpha = 1
            }, completion: nil)
            captureView.pauseCamera()
            return
        }
        
        if type == .record {
            if self.textGradientController.view.alpha > 0 {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    self.textGradientController.view.alpha = 0
                }, completion: nil)
            }
            captureView.resumeCamera()
            return
        }
    }
}

extension StoryRecordController: StoryRecordTopViewDelegate {
    func topViewDidPressBackButton() {
        NotificationCenter.default.post(name: .ScrollPage, object: 1)
    }
    
    func topViewDidPressFlashButton(isOn: Bool) {
        captureView.switchFlash()
    }
    
    func topViewDidPressCameraSwitchButton(isFront: Bool) {
        captureView.rotateCamera()
    }
    
    func topViewDidPressAvatarButton() {
        web.request(
        .storyList(page: 0, userId: user.userId),
        responseType: Response<StoryListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .failure(let error):
                logger.error(error)
            case .success(let response):
                let viewModels = response.list.map(StoryCellViewModel.init(model:))
                let storiesPlayViewController = StoriesPlayerViewController()
                storiesPlayViewController.stories = viewModels
                self.present(storiesPlayViewController, animated: true) {
                    storiesPlayViewController.initPlayer()
                }
            }
        }
    }
}
