//
//  StoryEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryEditController: BaseViewController, StoryEditView {
    var onCancelled: (() -> Void)?
    var onFinished: ((URL) -> Void)?
    var topic: Topic?
    
    private let fileURL: URL
    private let isPhoto: Bool
    private lazy var previewController = StoryFilterPreviewController(fileURL: self.fileURL, isPhoto: self.isPhoto)
    private var textController = StoryTextEditController()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryEdit"), for: .normal)
        button.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var pokeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryPoke"), for: .normal)
        button.addTarget(self, action: #selector(didPressPokeButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryConfirm"), for: .normal)
        button.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
        return button
    } ()
    
    private let pokeView = StoryPokeView()
    private var pokeCenterX: NSLayoutConstraint?
    private var pokeCenterY: NSLayoutConstraint?
    
    init(fileURL: URL, isPhoto: Bool) {
        self.fileURL = fileURL
        self.isPhoto = isPhoto
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        add(childViewController: previewController)
        add(childViewController: textController)
        textController.delegate = self
        textController.keyboardControl.delegate = self
        setupPokeView()
        setupControlButtons()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewController.stopPreview()
    }
    
    // MARK: - Private
    
    private func setupControlButtons() {
        view.addSubview(closeButton)
        closeButton.constrain(width: 40, height: 40)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.align(.top, to: view, inset: 10)
        view.addSubview(editButton)
        editButton.constrain(width: 50, height: 50)
        editButton.align(.left, to: view, inset: 10)
        editButton.align(.bottom, to: view, inset: 25)
        view.addSubview(pokeButton)
        pokeButton.equal(.size, to: editButton)
        pokeButton.centerY(to: editButton)
        pokeButton.align(.bottom, to: editButton)
        pokeButton.pin(.right, to: editButton, spacing: 15)
        view.addSubview(finishButton)
        finishButton.constrain(width: 50, height: 50)
        finishButton.centerY(to: editButton)
        finishButton.align(.right, to: view, inset: 10)
    }
    
    private func setupPokeView() {
        view.addSubview(pokeView)
        pokeView.constrain(width: 120, height: 120)
        pokeCenterX = pokeView.centerX(to: view)
        pokeCenterY = pokeView.centerY(to: view)
        pokeView.addGestureRecognizer(UIPanGestureRecognizer(target: self, action: #selector(didPan(_:))))
        pokeView.isHidden = true
    }
    
    @objc private func didPan(_ pan: UIPanGestureRecognizer) {
        switch pan.state {
        case .changed:
            let translation = pan.translation(in: view)
            pokeCenterX?.constant += translation.x
            pokeCenterY?.constant += translation.y
            pan.setTranslation(.zero, in: view)
            view.setNeedsLayout()
        case .ended:
            let maxOffsetX = (view.bounds.width - pokeView.bounds.width) * 0.5
            let maxOffsetY = (view.bounds.height - pokeView.bounds.height) * 0.5
            let offsetX = pokeCenterX?.constant ?? 0
            let offsetY = pokeCenterY?.constant ?? 0
            if offsetX < -maxOffsetX {
                pokeCenterX?.constant = -maxOffsetX
            } else if offsetX > maxOffsetX {
                pokeCenterX?.constant = maxOffsetX
            }
            if offsetY < -maxOffsetY {
                pokeCenterY?.constant = -maxOffsetY
            } else if offsetY > maxOffsetY {
                pokeCenterY?.constant = maxOffsetY
            }
            view.setNeedsLayout()
        default:
            break
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPressCloseButton() {
        onCancelled?()
    }
    
    @objc private func didPressEditButton() {
        textController.beginEditing()
    }
    
    @objc private func didPressPokeButton() {
        pokeView.isHidden = false
        pokeButton.isHidden = true
    }
    
    @objc private func didPressFinishButton() {
        
    }
}

extension StoryEditController: StoryTextEditControllerDelegate {
    func storyTextEditControllerDidBeginEditing() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.pokeView.alpha = 0
        }, completion: nil)
    }
    
    func storyTextEidtControllerDidEndEditing() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.pokeView.alpha = 1
        }, completion: nil)
    }
    
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer) {
        previewController.didPan(pan)
    }
}

extension StoryEditController: StoryKeyboardControlViewDelegate {
    func keyboardControlViewDidPressNextButton() {
        textController.endEditing()
    }
    
    func keyboardControlViewDidPressTopicButton() {
        textController.endEditing()
        let topic = TopicListController()
        addChildViewController(topic)
        topic.didMove(toParentViewController: self)
        view.addSubview(topic.view)
        topic.view.frame = view.bounds
        topic.view.alpha = 0
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            topic.view.alpha = 1
            self.textController.view.alpha = 0
            self.closeButton.alpha = 0
        }, completion: nil)
        topic.didFinish = { [weak self] topic in
            guard let `self` = self, let view = self.view.snapshotView(afterScreenUpdates: false) else { return }
            self.topic = topic
            self.view.addSubview(view)
            self.textController.topic = topic
            self.textController.beginEditing()
            view.frame = self.view.bounds
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                view.alpha = 0
                self.textController.view.alpha = 1
                self.closeButton.alpha = 1
            }, completion: { (_) in
                view.removeFromSuperview()
            })
        }
    }
}
