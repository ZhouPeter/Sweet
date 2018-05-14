//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryTextController: BaseViewController, StoryTextView {
    var onFinished: ((StoryText) -> Void)?
    
    private lazy var editController = StoryTextEditController()
    
    private lazy var topicButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("#添加话题", for: .normal)
        button.setTitleColor(UIColor(hex: 0xF8E71C), for: .normal)
        let image = #imageLiteral(resourceName: "TopicButton")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 17), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        button.addTarget(self, action: #selector(didPressTopicButton), for: .touchUpInside)
        button.alpha = 0
        return button
    } ()
    
    private lazy var nextButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setTitle("下一步", for: .normal)
        button.setTitleColor(.white, for: .normal)
        let image = #imageLiteral(resourceName: "NextButton")
            .resizableImage(withCapInsets: UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 17), resizingMode: .stretch)
        button.setBackgroundImage(image, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 15)
        button.contentEdgeInsets = UIEdgeInsets(top: 0, left: 15, bottom: 0, right: 15)
        button.addTarget(self, action: #selector(didPressNextButton), for: .touchUpInside)
        button.alpha = 0
        return button
    } ()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryBack"), for: .normal)
        button.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryDeleteLarge"), for: .normal)
        button.addTarget(self, action: #selector(didPressDeleteButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var editButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryEdit"), for: .normal)
        button.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var confirmButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryConfirm"), for: .normal)
        button.addTarget(self, action: #selector(didPressConfirmButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryClose"), for: .normal)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        return button
    } ()
    
    private let topicBottomInset: CGFloat = 50
    private var topicBottom: NSLayoutConstraint?
    private let keyboardObserver = KeyboardObserver()
    
    var enablePageScroll: Bool = true {
        didSet {
            NotificationCenter.default.post(
                name: enablePageScroll ? .EnablePageScroll : .DisablePageScroll,
                object: nil
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .gray
        setupEditController()
        setupTopicButton()
        setupNextButton()
        setupEditControls()
        keyboardObserver.observe { [weak self] in self?.handleKeyboard(with: $0) }
        hideEditControls(true)
    }
    
    // MARK: - Private
    
    private func setupEditController() {
        addChildViewController(editController)
        editController.didMove(toParentViewController: self)
        view.addSubview(editController.view)
        editController.view.fill(in: view)
    }
    
    private func setupTopicButton() {
        view.addSubview(topicButton)
        topicButton.constrain(height: 30)
        topicButton.align(.left, to: view, inset: 20)
        topicBottom = topicButton.align(.bottom, to: view, inset: topicBottomInset)
    }
    
    private func setupNextButton() {
        view.addSubview(nextButton)
        nextButton.constrain(height: 30)
        nextButton.align(.right, to: view, inset: 20)
        nextButton.align(.bottom, to: topicButton)
    }
    
    private func setupEditControls() {
        view.addSubview(backButton)
        view.addSubview(editButton)
        view.addSubview(confirmButton)
        view.addSubview(deleteButton)
        backButton.constrain(width: 40, height: 40)
        backButton.align(.left, to: view, inset: 10)
        backButton.align(.bottom, to: view, inset: 10)
        editButton.equal(.size, to: backButton)
        editButton.centerX(to: view)
        editButton.align(.bottom, to: backButton)
        confirmButton.equal(.size, to: backButton)
        confirmButton.align(.bottom, to: backButton)
        confirmButton.align(.right, to: view, inset: 10)
        view.addSubview(closeButton)
        closeButton.constrain(width: 40, height: 40)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.align(.top, to: view, inset: 10)
        closeButton.alpha = 0
    }
    
    private func handleKeyboard(with event: KeyboardEvent) {
        guard event.type == .willShow || event.type == .willHide || event.type == .willChangeFrame else { return }
        let height = (UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y)
        topicBottom?.constant = -(height > 0 ? height + 10 : topicBottomInset)
        UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
            self.view.layoutIfNeeded()
            self.topicButton.alpha = event.type == .willHide ? 0 : 1
            self.nextButton.alpha = self.topicButton.alpha
            self.closeButton.alpha = self.topicButton.alpha
        }, completion: nil)
        if event.type == .willShow {
            enablePageScroll = false
        } else if event.type == .willHide {
            logger.debug()
            enablePageScroll = true
        }
    }
    
    private func hideEditControls(_ isHidden: Bool, animated: Bool = false) {
        if animated {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(0.25)
            UIView.setAnimationCurve(.easeOut)
        }
        let alpha: CGFloat = isHidden ? 0 : 1
        backButton.alpha = alpha
        editButton.alpha = alpha
        confirmButton.alpha = alpha
        if animated {
            UIView.commitAnimations()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPressTopicButton() {
        logger.debug()
    }
    
    @objc private func didPressNextButton() {
        editController.endEditing()
    }
    
    @objc private func didPressBackButton() {
        
    }
    
    @objc private func didPressDeleteButton() {
        
    }
    
    @objc private func didPressEditButton() {
        
    }
    
    @objc private func didPressConfirmButton() {
        
    }

    @objc private func didPressCloseButton() {
        editController.clear()
    }
}
