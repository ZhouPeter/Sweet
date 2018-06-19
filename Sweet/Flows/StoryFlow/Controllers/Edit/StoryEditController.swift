//
//  StoryEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import TapticEngine
import SwiftyUserDefaults

final class StoryEditController: BaseViewController, StoryEditView {
    var onCancelled: (() -> Void)?
    var onFinished: ((URL) -> Void)?
    
    private let fileURL: URL
    private let isPhoto: Bool
    private var topic: String?
    private lazy var previewController = StoryFilterPreviewController(fileURL: self.fileURL, isPhoto: self.isPhoto)
    private var textController = StoryTextEditController()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        button.enableShadow()
        return button
    } ()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryEdit"), for: .normal)
        button.setTitle("编辑", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: -37, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -33, bottom: -23, right: 0)
        button.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var pokeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryPoke"), for: .normal)
        button.setTitle("戳住", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: -36, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 0, left: -33, bottom: -23, right: 0)
        button.addTarget(self, action: #selector(didPressPokeButton), for: .touchUpInside)
        button.alpha = self.isPhoto ? 0 : 1
        return button
    } ()
    
    private lazy var finishButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryConfirm"), for: .normal)
        button.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var deleteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryDelete"), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.setTitle("拖到这里删除", for: .normal)
        button.titleEdgeInsets = UIEdgeInsets(top: -90, left: -48, bottom: 0, right: 0)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 12, bottom: -13, right: 0)
        button.enableShadow()
        return button
    } ()
    
    private let pokeView = StoryPokeView()
    private var pokeCenterX: NSLayoutConstraint?
    private var pokeCenterY: NSLayoutConstraint?
    private let storyGenerator = StoryGenerator()
    private let editContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
    } ()
    private lazy var publisher = StoryPublisher()
    
    init(fileURL: URL, isPhoto: Bool, topic: String?) {
        self.fileURL = fileURL
        self.isPhoto = isPhoto
        self.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        add(childViewController: previewController)
        view.addSubview(editContainerView)
        editContainerView.fill(in: view)
        add(childViewController: textController, addView: false)
        editContainerView.addSubview(textController.view)
        previewController.view.fill(in: view)
        textController.view.fill(in: view)
        textController.delegate = self
        setupPokeView()
        setupControlButtons()
        textController.topic = topic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
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
        view.addSubview(deleteButton)
        deleteButton.constrain(width: 84, height: 84)
        deleteButton.align(.bottom, to: view, inset: 15)
        deleteButton.centerX(to: view)
        deleteButton.alpha = 0
    }
    
    private func hideControlButtons(_ isHidden: Bool) {
        let alpha: CGFloat = isHidden ? 0 : 1
        closeButton.alpha = alpha
        editButton.alpha = isHidden ? 0 : (textController.hasText ? 0 : 1)
        pokeButton.alpha = alpha
        finishButton.alpha = alpha
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
        case .began:
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.deleteButton.alpha = 0.5
                self.hideControlButtons(true)
            }, completion: nil)
        case .changed:
            if checkIfShouldDelete(with: pokeView.frame) {
                fade(view: pokeView, isFaded: true)
            } else {
                fade(view: pokeView, isFaded: false)
            }
            let translation = pan.translation(in: view)
            pokeCenterX?.constant += translation.x
            pokeCenterY?.constant += translation.y
            pan.setTranslation(.zero, in: view)
            view.setNeedsLayout()
        case .ended:
            if checkIfShouldDelete(with: pokeView.frame) {
                deletePokeView()
                pokeButton.isHidden = false
            } else {
                adjustPokeViewCenter()
                pokeButton.isHidden = true
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.deleteButton.alpha = 0
                self.hideControlButtons(false)
            }, completion: nil)
        default:
            break
        }
    }
    
    @discardableResult private func checkIfShouldDelete(with rect: CGRect) -> Bool {
        if deleteButton.frame.intersects(rect) {
            if deleteButton.alpha != 1 {
                TapticEngine.selection.feedback()
                UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                    self.deleteButton.alpha = 1
                }, completion: nil)
            }
            return true
        }
        if deleteButton.alpha != 0.5 {
            if deleteButton.alpha == 1 {
                TapticEngine.selection.feedback()
            }
            UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
                self.deleteButton.alpha = 0.5
            }, completion: nil)
        }
        return false
    }
    
    private func adjustPokeViewCenter() {
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
    }
    
    private func fade(view: UIView, isFaded: Bool) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            if isFaded && view.alpha != 0.5 {
                view.alpha = 0.5
            } else if !isFaded && view.alpha != 1 {
                view.alpha = 1
            }
        }, completion: nil)
    }
    
    private func deletePokeView() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.pokeView.center = self.deleteButton.center
            self.pokeView.transform = CGAffineTransform.identity.scaledBy(x: 0.5, y: 0.5)
            self.pokeView.alpha = 0
        }, completion: { (_) in
            self.pokeView.transform = CGAffineTransform.identity
            self.pokeView.center = self.view.center
            self.pokeView.isHidden = true
            self.pokeView.alpha = 1
            self.pokeCenterX?.constant = 0
            self.pokeCenterY?.constant = 0
        })
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
        pokeView.alpha = 1
        pokeButton.isHidden = true
    }
    
    @objc private func didPressFinishButton() {
        previewController.stopPreview()
        let image = editContainerView.screenshot()
        let filter = previewController.currentFilter()
        if isPhoto {
            storyGenerator.generateImage(with: fileURL, filter: filter, overlay: image) { [weak self] (url) in
                guard let `self` = self else { return }
                guard let url = url else {
                    logger.error("story generate failed")
                    return
                }
                self.publisher.publish(with: url, storyType: StoryType.image, topic: self.topic, completion: { result in
                    logger.debug(result)
                    Defaults[.isPersonalStoryChecked] = false
                    self.onFinished?(url)
                })
            }
        } else {
            storyGenerator.generateVideo(with: fileURL, filter: filter, overlay: image) { [weak self] (url) in
                guard let `self` = self else { return }
                guard let url = url else {
                    logger.error("story generate failed")
                    return
                }
                var pokeCenter: CGPoint?
                let type: StoryType
                if !self.pokeView.isHidden {
                    type = .poke
                    let centerX = (self.pokeView.center.x - self.view.bounds.width / 2) / (self.view.bounds.width / 2)
                    let centerY = (self.pokeView.center.y - self.view.bounds.width / 2) / (self.view.bounds.height / 2)
                    pokeCenter = CGPoint(
                        x: min(max(centerX, -0.5), 0.5),
                        y: min(max(centerY, -0.5), 0.5)
                    )
                } else {
                    type = .video
                }
                self.publisher.publish(
                    with: url,
                    storyType: type,
                    topic: self.topic,
                    pokeCenter: pokeCenter,
                    completion: { result in
                        logger.debug(result)
                        Defaults[.isPersonalStoryChecked] = false
                        self.onFinished?(url)
                })
            }
        }
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
            self.editButton.alpha = self.textController.hasText ? 0 : 1
            if !self.pokeView.isHidden {
                self.pokeView.alpha = 1
            }
        }, completion: nil)
    }
    
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer) {
        previewController.didPan(pan)
    }
    
    func storyTextEditControllerTextDeleteZoneDidBeginUpdate(_ rect: CGRect) {
        hideControlButtons(true)
    }
    
    func storyTextEditControllerTextDeleteZoneDidUpdate(_ rect: CGRect) {
        if checkIfShouldDelete(with: rect) {
            fade(view: textController.view, isFaded: true)
        } else {
            fade(view: textController.view, isFaded: false)
        }
    }
    
    func storyTextEditControllerTextDeleteZoneDidEndUpdate(_ rect: CGRect) {
        let isDeleted = checkIfShouldDelete(with: rect)
        if isDeleted {
            textController.deleteTextZone(at: deleteButton.center)
        }
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.deleteButton.alpha = 0
            self.editButton.alpha = isDeleted ? 1 : 0
            self.closeButton.alpha = 1
            self.finishButton.alpha = 1
            if !self.isPhoto {
                self.pokeButton.alpha = self.pokeView.isHidden ? 1 : 0
            }
        }, completion: { _ in
            self.textController.view.alpha = 1
        })
    }

    func storyTextEditControllerDidBeginChooseTopic() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.finishButton.alpha = 0
            self.closeButton.alpha = 0
            self.pokeButton.alpha = 0
            self.pokeView.alpha = 0
            self.editButton.alpha = 0
        }, completion: nil)
    }
    
    func storyTextEditControllerDidEndChooseTopic(_ topic: String?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.finishButton.alpha = 1
            self.closeButton.alpha = 1
            if self.isPhoto == false && self.pokeView.isHidden { self.pokeButton.alpha = 1 }
            self.editButton.alpha = self.textController.hasText ? 0 : 1
        }, completion: nil)
    }
}
