//
//  StoryRecordController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable type_body_length

import UIKit
import Hero
import SwiftyUserDefaults

final class StoryRecordController: BaseViewController, StoryRecordView {
    var onRecorded: ((URL, Bool, String?) -> Void)?
    var onTextChoosed: ((String?) -> Void)?
    var onAlbumChoosed: ((String?) -> Void)?
    var onDismissed: (() -> Void)?
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private let recordContainer = UIView()
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
    
    private lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Avatar"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(didPressAvatarButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var avatarCircle: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    } ()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "MenuClosed"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "MenuExpanded"), for: .selected)
        button.addTarget(self, action: #selector(didPressMenuButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "FlashOn"), for: .selected)
        button.addTarget(self, action: #selector(didPressFlashButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var cameraSwitchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "CameraBack"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "CameraFront"), for: .selected)
        button.addTarget(self, action: #selector(didPressCameraSwitchButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        if self.isDismissable {
            button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
            button.addTarget(self, action: #selector(didPressDismissButton), for: .touchUpInside)
        } else {
            button.setImage(#imageLiteral(resourceName: "RightArrow"), for: .normal)
            button.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        }
        return button
    } ()
    
    private var flashButtonCenterY: NSLayoutConstraint?
    private var cameraSwitchCenterY: NSLayoutConstraint?
    private var current = StoryRecordType.record
    private let user: User
    private let isDismissable: Bool
    
    init(user: User, topic: String? = nil, isDismissable: Bool = false) {
        self.user = user
        self.topic = topic
        self.isDismissable = isDismissable
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        logger.debug()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        
        view.addSubview(recordContainer)
        recordContainer.backgroundColor = .clear
        recordContainer.fill(in: view)
        topicButton.updateTopic(topic ?? "添加标签")
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
        cancelDelayCameraClose()
        if blurCoverView.isHidden == false {
            resumeCamera(true)
        } else if captureView.isStarted == false {
            captureView.startCaputre()
            captureView.resumeCamera()
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.hideTopControls(false)
            self.bottomView.alpha = 1
            self.topicButton.alpha = 1
            self.avatarCircle.alpha = Defaults[.isPersonalStoryChecked] == false ? 1 : 0
        }, completion: nil)
        shootButton.resetProgress()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delayCameraClose()
        if isDismissable == false {
            topic = nil
        }
        isShooting = false
        isStoryEditing = false
        shootButton.alpha = 1
        toggleOffMenu()
    }
    
    private var isPrepared = false
    
    func prepare() {
        guard isPrepared == false else { return }
        self.isPrepared = true
        guard TLAuthorizedManager.checkAuthorization(with: .camera) else { return }
        self.captureView.setupCamera {
            guard TLAuthorizedManager.checkAuthorization(with: .mic) else { return }
            self.captureView.enableAudio()
        }
    }
    
    // MARK: - Delay camera close
    
    private let cameraDelayQueue = DispatchQueue.global()
    private var cameraCloseDelay: DispatchWorkItem?
    
    private func delayCameraClose() {
        cameraCloseDelay?.cancel()
        cameraCloseDelay = DispatchWorkItem(block: { [weak self] in
            logger.debug()
            self?.resumeCamera(false)
        })
        if let item = cameraCloseDelay {
            cameraDelayQueue.asyncAfter(deadline: .now() + 1, execute: item)
        }
    }
    
    private func cancelDelayCameraClose() {
        cameraCloseDelay?.cancel()
        cameraCloseDelay = nil
    }
    
    // MARK: - Private
    
    @objc private func didTapTextGradientView() {
        enablePageScroll = false
        onTextChoosed?(topic)
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
            self.hideTopControls(true)
            self.bottomView.alpha = 0
            self.shootButton.alpha = 0
            self.topicButton.alpha = 0
        }, completion: nil)
        let dismissTopic = { [weak self] in
            guard let `self` = self, let view = self.view.snapshotView(afterScreenUpdates: false) else { return }
            self.view.addSubview(view)
            view.frame = self.view.bounds
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 0
                self.hideTopControls(false)
                self.bottomView.alpha = 1
                self.shootButton.alpha = 1
                self.topicButton.alpha = 1
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
        topic.onFinished = { [weak self] topic in
            self?.topic = topic
            dismissTopic()
        }
        topic.onCancelled = dismissTopic
    }
    
    // MARK: - Camera
    
    private var isShooting = false
    private var isStoryEditing = false
    
    private func shootDidBegin() {
        guard isShooting == false else { return }
        isShooting = true
        UIView.animate(withDuration: 0.25) {
            self.hideTopControls(true)
            self.bottomView.alpha = 0
            self.topicButton.alpha = 0
        }
        captureView.startRecording()
    }
    
    private func shootDidEnd(with interval: TimeInterval) {
        guard isStoryEditing == false else { return }
        isStoryEditing = true
        if interval < 1 {
            captureView.capturePhoto { [weak self] (url) in
                if let url = url {
                    self?.edit(with: url, isPhoto: true)
                } else {
                    self?.isShooting = false
                }
            }
        } else {
            captureView.finishRecording { [weak self] (url) in
                if let url = url {
                    self?.edit(with: url, isPhoto: false)
                } else {
                    self?.isShooting = false
                }
            }
        }
    }
    
    private func checkAuthorized() {
        let cameraAuthorization = TLAuthorizedManager.checkAuthorization(with: .camera)
        let micAuthorization = TLAuthorizedManager.checkAuthorization(with: .mic)
        
        if cameraAuthorization && micAuthorization {
            if cameraAuthorization {
                startCamera { if micAuthorization { self.captureView.enableAudio() } }
            } else if micAuthorization {
                captureView.enableAudio()
            }
        } else {
            let authorizedVC = TLStoryAuthorizationController()
            authorizedVC.delegate = self
            add(childViewController: authorizedVC)
        }
    }
    
    private func startCamera(callback: (() -> Void)? = nil) {
        captureView.setupCamera {
            self.captureView.startCaputre(callback: {
                self.captureView.resumeCamera(callback: {
                    callback?()
                })
            })
        }
    }
    
    private func resumeCamera(_ isOpen: Bool) {
        if isOpen {
            captureView.startCaputre()
            captureView.resumeCamera()
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
        recordContainer.addSubview(avatarButton)
        recordContainer.addSubview(avatarCircle)
        recordContainer.addSubview(cameraSwitchButton)
        recordContainer.addSubview(flashButton)
        flashButton.alpha = 0
        cameraSwitchButton.alpha = 0
        recordContainer.addSubview(menuButton)
        recordContainer.addSubview(backButton)
        avatarButton.constrain(width: 40, height: 40)
        avatarButton.align(.left, to: recordContainer, inset: 10)
        avatarButton.align(.top, to: recordContainer, inset: 10)
        avatarCircle.equal(.size, to: avatarButton)
        avatarCircle.center(to: avatarButton)
        menuButton.constrain(width: 40, height: 40)
        menuButton.centerY(to: avatarButton)
        menuButton.pin(.right, to: avatarButton, spacing: 10)
        flashButton.constrain(width: 40, height: 40)
        flashButton.centerX(to: menuButton)
        flashButtonCenterY = flashButton.centerY(to: menuButton)
        cameraSwitchButton.equal(.size, to: flashButton)
        cameraSwitchButton.centerX(to: flashButton)
        cameraSwitchCenterY = cameraSwitchButton.centerY(to: menuButton)
        backButton.constrain(width: 30, height: 30)
        backButton.align(.right, to: recordContainer, inset: 10)
        backButton.centerY(to: menuButton)
    }
    
    // MARK: - Actions
    
    @objc private func didPressAvatarButton() {
        web.request(
            .storyList(page: 0, userId: user.userId),
            responseType: Response<StoryListResponse>.self) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    logger.error(error)
                case .success(let response):
                    Defaults[.isPersonalStoryChecked] = true
                    let viewModels = response.list.map(StoryCellViewModel.init(model:))
                    let storiesPlayViewController = StoriesPlayerViewController(user: self.user)
                    storiesPlayViewController.stories = viewModels
                    self.present(storiesPlayViewController, animated: true) {
                        storiesPlayViewController.initPlayer()
                    }
                }
        }
    }
    
    @objc private func didPressMenuButton() {
        toggleMenu()
    }
    
    private func hideTopControls(_ isHidden: Bool) {
        toggleOffMenu()
        let alpha: CGFloat = isHidden ? 0 : 1
        avatarButton.alpha = alpha
        avatarCircle.alpha = alpha
        backButton.alpha = alpha
        menuButton.alpha = alpha
    }
    
    private func toggleOffMenu() {
        guard menuButton.isSelected else { return }
        toggleMenu()
    }
    
    private func toggleMenu() {
        menuButton.isSelected = !menuButton.isSelected
        var alpha: CGFloat = 0
        if menuButton.isSelected {
            alpha = 1
            let offset: CGFloat = 40
            flashButtonCenterY?.constant = offset
            cameraSwitchCenterY?.constant = offset * 2
        } else {
            flashButtonCenterY?.constant = 0
            cameraSwitchCenterY?.constant = 0
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.view.layoutIfNeeded()
            self.flashButton.alpha = alpha
            self.cameraSwitchButton.alpha = alpha
        }, completion: nil)
    }
    
    @objc private func didPressFlashButton() {
        toggleOffMenu()
        captureView.switchFlash()
        flashButton.isSelected = !flashButton.isSelected
    }
    
    @objc private func didPressCameraSwitchButton() {
        toggleOffMenu()
        captureView.rotateCamera()
        cameraSwitchButton.isSelected = !cameraSwitchButton.isSelected
    }
    
    @objc private func didPressBackButton() {
        toggleOffMenu()
        NotificationCenter.default.post(name: .ScrollPage, object: 1)
    }
    
    @objc private func didPressDismissButton() {
        toggleOffMenu()
        captureView.stopCapture()
        onDismissed?()
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
            onAlbumChoosed?(topic)
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
            captureView.startCaputre()
            captureView.resumeCamera()
            return
        }
    }
}
