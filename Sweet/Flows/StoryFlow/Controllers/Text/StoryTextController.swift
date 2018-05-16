//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoryTextControllerDelegate: class {
    func storyTextControllerDidFinish(_ controller: StoryTextController)
}

final class StoryTextController: BaseViewController, StoryTextView {
    var onFinished: ((StoryText) -> Void)?
    weak var delegate: StoryTextControllerDelegate?
    var topic: Topic?
    
    private lazy var gradientView = GradientSwitchView()
    
    private lazy var editController = StoryTextEditController()
    private let topicBottomInset: CGFloat = 50
    private var topicBottom: NSLayoutConstraint?
    private let keyboardObserver = KeyboardObserver()
    
    private var isPublishing = false {
        didSet { enablePageScroll = !isPublishing }
    }
    
    private lazy var editContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryDeleteLarge"), for: .normal)
        button.addTarget(self, action: #selector(didPressDeleteButton), for: .touchUpInside)
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
    
    private var enablePageScroll: Bool = true {
        didSet {
            if isPublishing && enablePageScroll { return }
            NotificationCenter.default.post(
                name: enablePageScroll ? .EnablePageScroll : .DisablePageScroll,
                object: nil
            )
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(gradientView)
        gradientView.fill(in: view)
        gradientView.changeColors([UIColor(hex: 0x3023AE), UIColor(hex: 0xC86DD7)])
        gradientView.changeMode(.linearWithPoints(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: view.bounds.width, y: view.bounds.height)
            )
        )
        view.addSubview(editContainer)
        editContainer.fill(in: view)
        setupEditController()
        setupTopicButton()
        setupNextButton()
        setupEditControls()
        keyboardObserver.observe { [weak self] in self?.handleKeyboard(with: $0) }
        hideEditControls(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editController.beginEditing()
    }
    
    // MARK: - Private
    
    private func setupEditController() {
        addChildViewController(editController)
        editController.didMove(toParentViewController: self)
        editContainer.addSubview(editController.view)
        editController.view.fill(in: editContainer)
    }
    
    private func setupTopicButton() {
        editContainer.addSubview(topicButton)
        topicButton.constrain(height: 30)
        topicButton.align(.left, to: view, inset: 20)
        topicBottom = topicButton.align(.bottom, to: view, inset: topicBottomInset)
    }
    
    private func setupNextButton() {
        editContainer.addSubview(nextButton)
        nextButton.constrain(height: 30)
        nextButton.align(.right, to: view, inset: 20)
        nextButton.align(.bottom, to: topicButton)
    }
    
    private func setupEditControls() {
        editContainer.addSubview(confirmButton)
        editContainer.addSubview(deleteButton)
        confirmButton.centerX(to: view)
        confirmButton.align(.bottom, to: view, inset: 10)
        editContainer.addSubview(closeButton)
        closeButton.constrain(width: 40, height: 40)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.align(.top, to: view, inset: 10)
    }
    
    private func handleKeyboard(with event: KeyboardEvent) {
        guard event.type == .willShow || event.type == .willHide || event.type == .willChangeFrame else { return }
        let height = (UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y)
        topicBottom?.constant = -(height > 0 ? height + 10 : topicBottomInset)
        UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
            self.view.layoutIfNeeded()
            self.topicButton.alpha = event.type == .willHide ? 0 : 1
            self.nextButton.alpha = self.topicButton.alpha
        }, completion: nil)
        
        if isPublishing { return }
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
        confirmButton.alpha = alpha
        if animated {
            UIView.commitAnimations()
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPressTopicButton() {
        editController.endEditing()
        let topic = TopicListController()
        addChildViewController(topic)
        topic.didMove(toParentViewController: self)
        view.addSubview(topic.view)
        topic.view.frame = view.bounds
        topic.view.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            topic.view.alpha = 1
            self.editContainer.alpha = 0
        }, completion: { _ in
            self.enablePageScroll = false
        })
        topic.didFinish = { [weak self] topic in
            self?.enablePageScroll = true
            guard let `self` = self, let view = self.view.snapshotView(afterScreenUpdates: false) else { return }
            self.topic = topic
            self.view.addSubview(view)
            self.editController.topic = topic
            self.editController.beginEditing()
            view.frame = self.view.bounds
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 0
                self.editContainer.alpha = 1
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
    }
    
    @objc private func didPressNextButton() {
        guard editController.hasText else { return }
        isPublishing = true
        editController.endEditing()
        editController.hidesTopicWithoutText = true
        hideEditControls(false, animated: true)
    }
    
    @objc private func didPressDeleteButton() {
        
    }
    
    @objc private func didPressConfirmButton() {
        isPublishing = false
        enablePageScroll = true
        delegate?.storyTextControllerDidFinish(self)
    }
    
    @objc private func didPressCloseButton() {
        editController.endEditing()
        dismiss(animated: true, completion: nil)
        delegate?.storyTextControllerDidFinish(self)
    }
}
