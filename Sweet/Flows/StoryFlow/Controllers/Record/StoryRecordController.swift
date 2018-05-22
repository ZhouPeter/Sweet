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
    var onRecorded: ((URL, Bool) -> Void)?
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
    
    private var shootButton = ShootButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigation()
        
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
        navigationController?.setNavigationBarHidden(true, animated: false)
        resumeCamera(true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        resumeCamera(false)
    }
    
    // MARK: - Private
    
    @objc private func didTapTextGradientView() {
        enablePageScroll = false
        let controller = StoryTextController(source: .text)
        controller.delegate = self
        add(childViewController: controller)
    }

    private func edit(with source: StorySource) {
        enablePageScroll = false
        let controller = StoryTextController(source: source)
        controller.delegate = self
        add(childViewController: controller)
    }
    
    // MARK: - Camera
    
    private func shootDidBegin() {
        UIView.animate(withDuration: 0.25) {
            self.topView.alpha = 0
            self.bottomView.alpha = 0
        }
        captureView.startRecording()
    }
    
    private func shootDidEnd(with interval: TimeInterval) {
        UIView.animate(withDuration: 0.25, delay: 0.5, options: [.curveEaseOut], animations: {
            self.topView.alpha = 1
            self.bottomView.alpha = 1
        }, completion: nil)
        if interval < 1 {
            captureView.capturePhoto { [weak self] (url) in
                if let url = url {
                    self?.edit(with: .image(fileURL: url))
                }
            }
        } else {
            captureView.finishRecording { [weak self] (url) in
                if let url = url {
                    self?.edit(with: .video(fileURL: url))
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
        navigationController?.hero.navigationAnimationType = .fade
        navigationController?.hero.isEnabled = true
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

extension StoryRecordController: StoryTextControllerDelegate {
    func storyTextControllerDidFinish(_ controller: StoryTextController, overlay: UIImage?) {
        remove(childViewController: controller)
        enablePageScroll = true
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
        } else {
            if self.textGradientController.view.alpha > 0 {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    self.textGradientController.view.alpha = 0
                }, completion: nil)
            }
            if type == .record {
                captureView.resumeCamera()
            }
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
        
    }
}
