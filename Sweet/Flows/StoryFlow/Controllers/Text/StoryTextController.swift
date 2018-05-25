//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoryTextControllerDelegate: class {
    func storyTextControllerDidFinish(_ controller: StoryTextController, overlay: UIImage?)
}

enum StorySource {
    case text
    case image(fileURL: URL)
    case video(fileURL: URL)
}

final class StoryTextController: BaseViewController, StoryTextView {
    var onFinished: ((StoryText) -> Void)?
    weak var delegate: StoryTextControllerDelegate?
    var topic: String?
    let source: StorySource
    
    private lazy var gradientView = GradientSwitchView()
    private var filterPreviewController: StoryFilterPreviewController?
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
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryDelete"), for: .normal)
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
    
    init(source: StorySource) {
        self.source = source
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        automaticallyDisablePageScroll = false
        switch source {
        case .text:
            setupGradientView()
        case let .image(url):
            let controller = StoryFilterPreviewController(fileURL: url, isPhoto: true)
            add(childViewController: controller)
            filterPreviewController = controller
        case let .video(url):
            let controller = StoryFilterPreviewController(fileURL: url, isPhoto: false)
            add(childViewController: controller)
            filterPreviewController = controller
        }
        
        view.addSubview(editContainer)
        editContainer.fill(in: view)
        setupEditController()
        setupEditControls()
        keyboardObserver.observe { [weak self] in self?.handleKeyboard(with: $0) }
        hideEditControls(true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editController.beginEditing()
    }
    
    // MARK: - Private
    
    private func setupGradientView() {
        view.addSubview(gradientView)
        gradientView.fill(in: view)
        gradientView.changeColors([UIColor(hex: 0x3023AE), UIColor(hex: 0xC86DD7)])
        gradientView.changeMode(.linearWithPoints(
            start: CGPoint(x: 0, y: 0),
            end: CGPoint(x: view.bounds.width, y: view.bounds.height)
            )
        )
    }
    
    private func setupEditController() {
        addChildViewController(editController)
        editController.didMove(toParentViewController: self)
        editContainer.addSubview(editController.view)
        editController.view.fill(in: editContainer)
        editController.delegate = self
    }
    
    private func setupEditControls() {
        editContainer.addSubview(confirmButton)
        editContainer.addSubview(deleteButton)
        confirmButton.constrain(width: 50, height: 50)
        confirmButton.centerX(to: view)
        confirmButton.align(.bottom, to: view, inset: 10)
        editContainer.addSubview(closeButton)
        closeButton.constrain(width: 50, height: 50)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.align(.top, to: view, inset: 10)
    }
    
    private func handleKeyboard(with event: KeyboardEvent) {
        guard event.type == .willShow || event.type == .willHide || event.type == .willChangeFrame else { return }
        let height = (UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y)
        topicBottom?.constant = -(height > 0 ? height + 10 : topicBottomInset)
        UIView.animate(withDuration: event.duration, delay: 0.0, options: [event.options], animations: {
            self.view.layoutIfNeeded()
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
        topic.onFinished = { [weak self] topic in
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
        if case .text = source, !editController.hasText { return }
        isPublishing = true
        editController.endEditing()
        hideEditControls(false, animated: true)
    }
    
    @objc private func didPressDeleteButton() {
        
    }
    
    @objc private func didPressConfirmButton() {
        isPublishing = false
        enablePageScroll = true
    }
    
    @objc private func didPressCloseButton() {
        editController.endEditing()
//        dismiss(animated: true, completion: nil)
        navigationController?.popViewController(animated: true)
    }
}

extension StoryTextController: StoryTextEditControllerDelegate {
    func storyTextEditControllerDidBeginEditing() {
        
    }
    
    func storyTextEidtControllerDidEndEditing() {
        
    }
    
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer) {
        filterPreviewController?.didPan(pan)
    }
}
