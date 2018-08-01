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
import Kingfisher

extension Notification.Name {
    static let avatarFakeImageUpdate = Notification.Name(rawValue: "AvatarFakeImageUpdate")
}

final class StoryRecordController: BaseViewController, StoryRecordView {
    var onRecorded: ((URL, Bool, String?) -> Void)?
    var onTextChoosed: ((String?) -> Void)?
    var onAlbumChoosed: ((String?) -> Void)?
    var onDismissed: (() -> Void)?
    var onAvatarButtonPressed: (() -> Void)?
    var isAvatarCircleAnamtionEnabled: Bool = false
    
    override var prefersStatusBarHidden: Bool {
        if UIScreen.isIphoneX() {
            return false
        }
        return true
    }
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
            updateTopicButton()
        }
    }
    
    private var shootButton = ShootButton()
    
    private lazy var topicButton: UIButton = {
        let button = UIButton(topic: "添加标签")
        button.addTarget(self, action: #selector(didPressTopicButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var avatarFakeView: UIImageView = {
        let view = UIImageView()
        view.backgroundColor = .clear
        view.contentMode = .scaleAspectFill
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        return view
    } ()
    
    private lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.addTarget(self, action: #selector(didPressAvatarButton), for: .touchUpInside)
        button.kf.setImage(with: URL(string: self.user.avatar), for: .normal)
        return button
    } ()
    
    private lazy var avatarCircleWhite: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "AvatarCircleWhite")
        return view
    } ()
    
    private lazy var avatarCircle: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        view.image = UIImage(named: "AvatarCircleOrange")
        return view
    } ()
    
    private lazy var avatarCircleMask: CAShapeLayer = {
        let layer = CAShapeLayer()
        layer.lineWidth = 3
        layer.lineCap = kCALineCapRound
        layer.fillColor = nil
        layer.strokeColor = UIColor.white.cgColor
        layer.transform = CATransform3DMakeRotation(-CGFloat.pi * 0.5, 0, 0, 1)
        return layer
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.hero.modifiers = [.backgroundColor(.black)]
        view.addSubview(recordContainer)
        recordContainer.backgroundColor = .clear
        if UIScreen.isIphoneX() {
            recordContainer.align(.top, to: view, inset: UIScreen.safeTopMargin())
            recordContainer.centerX(to: view)
            recordContainer.constrain(width: view.bounds.width, height: view.bounds.width * (16.0/9))
            recordContainer.clipsToBounds = true
            recordContainer.layer.cornerRadius = 7
        } else {
            recordContainer.fill(in: view)
        }
        updateTopicButton()
        setupCaptureView()
        setupTopView()
        setupShootButton()
        setupBottomView()
        setupCoverView()
        checkAuthorized()
        let tap = UITapGestureRecognizer(target: self, action: #selector(toggleCameraPosition))
        tap.numberOfTapsRequired = 2
        recordContainer.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveAvatarFakeImageNote(_:)),
            name: .avatarFakeImageUpdate,
            object: nil
        )
    }
    
    @objc func didReceiveAvatarFakeImageNote(_ note: Notification) {
        avatarFakeView.image = (note.object as? UIImage)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if UIScreen.isIphoneX() {
            NotificationCenter.default.post(name: .WhiteStatusBar, object: nil)
        }
        setupNavigation()
        cancelDelayCameraClose()
        if blurCoverView.isHidden == false {
            resumeCamera(true)
        } else if captureView.isPaused || captureView.isStarted == false {
            captureView.startCaputre()
            captureView.resumeCamera()
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.hideTopControls(false)
            self.bottomView.alpha = 1
            self.topicButton.alpha = 1
        }, completion: nil)
        shootButton.resetProgress()
        avatarCircle.isHidden = true
        chooseCameraRecord()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        animateAvatarCircle()
    }
    
    private func animateAvatarCircle() {
        if isAvatarCircleAnamtionEnabled {
            isAvatarCircleAnamtionEnabled = false
            avatarCircle.isHidden = false
            let animation = CABasicAnimation(keyPath: "strokeEnd")
            animation.fromValue = 0
            animation.toValue = 1
            animation.duration = 0.5
            animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut)
            avatarCircleMask.add(animation, forKey: nil)
        } else {
            if Defaults[.isPersonalStoryChecked] {
                avatarCircle.isHidden = true
            } else {
                avatarCircle.isHidden = false
            }
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        avatarCircleMask.frame = CGRect(origin: .zero, size: avatarCircle.bounds.size)
        avatarCircleMask.path = UIBezierPath(ovalIn: avatarCircleMask.bounds.insetBy(dx: 1.5, dy: 1.5)).cgPath
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        delayCameraClose()
        avatarFakeView.image = nil
        if isDismissable == false {
            topic = nil
        }
        isShooting = false
        isStoryEditing = false
        shootButton.alpha = 1
        toggleOffMenu()
    }
    
    func chooseCameraRecord() {
        guard current != .record else { return }
        bottomView.selectBottomButton(at: 1, animated: false)
        switchStoryType(.record, animated: false)
    }

    func prepare() {
        guard TLAuthorizedManager.checkAuthorization(with: .camera) else { return }
        captureView.setupCamera {
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
    
    private func updateTopicButton() {
        if let topic = topic {
            topicButton.updateTopic(topic)
        } else {
            topicButton.updateTopic("添加标签", withHashTag: false)
        }
    }
    
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
        if UIScreen.isIphoneX() {
            bottomView.pin(.bottom, to: recordContainer)
            bottomView.constrain(height: 40)
            bottomView.isIndicatorHidden = true
        } else {
            bottomView.align(.bottom, to: view)
            bottomView.constrain(height: 64)
        }
        bottomView.align(.left, to: view)
        bottomView.align(.right, to: view)
        bottomView.delegate = self
    }
    
    private func setupShootButton() {
        recordContainer.addSubview(shootButton)
        shootButton.centerX(to: recordContainer)
        shootButton.constrain(width: 76, height: 76)
        if UIScreen.isIphoneX() {
            shootButton.align(.bottom, to: recordContainer, inset: 30)
        } else {
            shootButton.align(.bottom, to: view, inset: 64)
        }
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
        recordContainer.addSubview(avatarFakeView)
        recordContainer.addSubview(avatarButton)
        avatarButton.addSubview(avatarCircleWhite)
        recordContainer.addSubview(avatarCircle)
        recordContainer.addSubview(cameraSwitchButton)
        recordContainer.addSubview(flashButton)
        flashButton.alpha = 0
        cameraSwitchButton.alpha = 0
        recordContainer.addSubview(menuButton)
        recordContainer.addSubview(backButton)
        avatarButton.constrain(width: 39, height: 39)
        avatarButton.align(.left, to: recordContainer, inset: 10)
        avatarButton.align(.top, to: recordContainer, inset: 10)
        avatarFakeView.fill(in: avatarButton)
        avatarCircle.constrain(width: 40, height: 40)
        avatarCircle.center(to: avatarButton)
        avatarCircle.layer.mask = avatarCircleMask
        avatarCircleWhite.equal(.size, to: avatarCircle)
        avatarCircleWhite.center(to: avatarButton)
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
        avatarFakeView.hero.id = "avatar"
    }
    
    // MARK: - Actions
    
    @objc private func didPressAvatarButton() {
        onAvatarButtonPressed?()
    }
    
    @objc private func didPressMenuButton() {
        toggleMenu()
    }
    
    private func hideTopControls(_ isHidden: Bool) {
        toggleOffMenu()
        let alpha: CGFloat = isHidden ? 0 : 1
        avatarButton.alpha = alpha
        avatarFakeView.isHidden = isHidden
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
        toggleCameraPosition()
    }
    
    @objc private func toggleCameraPosition() {
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
    
    func requestAllAuthorizeSuccess() {
        if Defaults[.isStoryRecordGuideShown] == false {
            Guide.showStoryRecordTip()
            Defaults[.isStoryRecordGuideShown] = true
        }
    }
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
    
    private func switchStoryType(_ type: StoryRecordType, animated: Bool = true) {
        current = type
        let showTextGradient: (Bool) -> Void = { [weak self] isShown in
            let alpha: CGFloat = isShown ? 1 : 0
            guard let `self`  = self else { return }
            if animated {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    self.textGradientController.view.alpha = alpha
                }, completion: nil)
            } else {
                self.textGradientController.view.alpha = alpha
            }
        }
        
        if type == .text {
            if textGradientController.view.superview == nil {
                addChildViewController(textGradientController)
                textGradientController.didMove(toParentViewController: self)
                view.insertSubview(textGradientController.view, belowSubview: bottomView)
                if UIScreen.isIphoneX() {
                    textGradientController.view.fill(in: recordContainer)
                    textGradientController.view.clipsToBounds = true
                    textGradientController.view.layer.cornerRadius = 7
                } else {
                    textGradientController.view.fill(in: view)
                }
            }
            showTextGradient(true)
            captureView.pauseCamera()
            return
        }
        
        if type == .record {
            showTextGradient(false)
            captureView.startCaputre()
            captureView.resumeCamera()
            return
        }
    }
}
