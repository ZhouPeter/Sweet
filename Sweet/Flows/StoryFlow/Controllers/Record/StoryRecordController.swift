//
//  StoryRecordController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Hero

private let buttonWidth: CGFloat = 70
private let buttonSpacing: CGFloat = 10

final class StoryRecordController: BaseViewController, StoryRecordView {
    var onRecorded: ((URL, Bool) -> Void)?
    
    private let topView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    } ()
    
    private let bottomView: UIView = {
        let view = UIView(frame: .zero)
        view.backgroundColor = .clear
        return view
    } ()
    
    private lazy var textGradientController: TextGradientController = {
        let controller = TextGradientController()
        controller.view.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(didTapTextGradientView))
        )
        return controller
    } ()
    
    private var captureController = VideoCaptureController()
    
    private lazy var renderView: UIView = {
        let view = UIView(frame: self.view.bounds)
        view.backgroundColor = .black
        return view
    } ()
    
    private var enablePageScroll: Bool = true {
        didSet {
            NotificationCenter.default.post(
                name: enablePageScroll ? .EnablePageScroll : .DisablePageScroll,
                object: nil
            )
        }
    }
    
    private var buttons = [UIButton]()
    private let indicator = UIImageView(image: #imageLiteral(resourceName: "ArrowIndicator"))
    private var indicatorCenterX: NSLayoutConstraint?
    
    private var shootButton = ShootButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupNavigation()
        setupCaptureView()
        setupTopView()
        setupShootButton()
        setupBottomView()
        selectBottomButton(at: 1, animated: false)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        captureController.startPreview()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        captureController.stopPreview()
    }
    
    // MARK: - Actions
    
    @objc private func didPressBottomButton(_ button: UIButton) {
        selectBottomButton(at: button.tag, animated: true)
        if button.tag == 0 {
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
            captureController.stopPreview()
        } else {
            if self.textGradientController.view.alpha > 0 {
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    self.textGradientController.view.alpha = 0
                }, completion: nil)
            }
            if button.tag == 1 {
                captureController.startPreview()
            }
        }
    }
    
    // MARK: - Private
    
    @objc private func didTapTextGradientView() {
        enablePageScroll = false
        let controller = StoryTextController(source: .text)
        controller.delegate = self
        add(childViewController: controller)
    }
    
    private func shootDidBegin() {
        captureController.startRecord()
    }
    
    private func shootDidEnd(with interval: TimeInterval) {
        if interval < 1 {
            captureController.cancelRecord()
            captureController.takeAPhoto { (url) in
                logger.debug(url)
            }
        } else {
            captureController.finishRecord { (url) in
                logger.debug(url)
            }
        }
    }
    
    private func selectBottomButton(at index: Int, animated: Bool) {
        indicatorCenterX?.constant = CGFloat(index - 1) * (buttonWidth + buttonSpacing)
        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.2)
            UIView.setAnimationCurve(.easeOut)
        }
        buttons.enumerated().forEach { (offset, button) in
            button.alpha = offset == index ? 1 : 0.5
        }
        view.layoutIfNeeded()
        if animated {
            UIView.commitAnimations()
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
        setupBottomButtons()
    }
    
    private func setupBottomButtons() {
        let textButton = makeButton(withTitle: "文字", tag: 0, action: #selector(didPressBottomButton(_:)))
        let shootButton = makeButton(withTitle: "拍摄", tag: 1, action: #selector(didPressBottomButton(_:)))
        let albumButton = makeButton(withTitle: "相册", tag: 2, action: #selector(didPressBottomButton(_:)))
        bottomView.addSubview(textButton)
        bottomView.addSubview(shootButton)
        bottomView.addSubview(albumButton)
        let height: CGFloat = 40
        textButton.constrain(width: buttonWidth, height: height)
        shootButton.constrain(width: buttonWidth, height: height)
        albumButton.constrain(width: buttonWidth, height: height)
        shootButton.center(to: bottomView)
        textButton.pin(.left, to: shootButton, spacing: buttonSpacing)
        textButton.centerY(to: shootButton)
        albumButton.pin(.right, to: shootButton, spacing: buttonSpacing)
        albumButton.centerY(to: shootButton)
        buttons.append(textButton)
        buttons.append(shootButton)
        buttons.append(albumButton)
        
        bottomView.addSubview(indicator)
        indicator.constrain(width: 30, height: 30)
        indicator.pin(.bottom, to: shootButton, spacing: -10)
        indicatorCenterX = indicator.centerX(to: shootButton)
    }
    
    private func setupShootButton() {
        view.addSubview(shootButton)
        shootButton.centerX(to: view)
        shootButton.constrain(width: 90, height: 90)
        shootButton.align(.bottom, to: view, inset: 64)
        shootButton.trackingDidStart = { [weak self] in self?.shootDidBegin() }
        shootButton.trackingDidEnd = { [weak self] interval in self?.shootDidEnd(with: interval) }
    }
    
    private func setupCaptureView() {
        view.addSubview(renderView)
        renderView.fill(in: view)
        captureController.render(in: view)
    }
    
    private func setupTopView() {
        view.addSubview(topView)
        topView.constrain(height: 64)
        topView.align(.top, to: view)
        topView.align(.left, to: view)
        topView.align(.right, to: view)
        
        let backButton = UIButton()
        backButton.setImage(#imageLiteral(resourceName: "RightArrow"), for: .normal)
        topView.addSubview(backButton)
        backButton.constrain(width: 30, height: 30)
        backButton.align(.top, to: topView, inset: 15)
        backButton.align(.right, to: topView, inset: 5)
    }
    
    private func makeButton(withTitle title: String, tag: Int, action: Selector) -> UIButton {
        let button = UIButton()
        button.setTitle(title, for: .normal)
        button.tag = tag
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }
}

extension StoryRecordController: StoryTextControllerDelegate {
    func storyTextControllerDidFinish(_ controller: StoryTextController) {
        remove(childViewController: controller)
        enablePageScroll = true
    }
}
