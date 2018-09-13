//
//  StoryEditController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable file_length
// swiftlint:disable type_body_length

import UIKit
import TapticEngine
import SwiftyUserDefaults
import PKHUD

final class StoryEditController: BaseViewController, StoryEditView, StoryEditCancellable {
    var onCancelled: (() -> Void)?
    var onFinished: (() -> Void)?
    var presentable: UIViewController { return self }
    private let fileURL: URL
    private let isPhoto: Bool
    private var topic: String?
    private let source: StoryMediaSource
    private lazy var previewController =
        StoryFilterPreviewController(fileURL: self.fileURL, isPhoto: self.isPhoto, isScaleFilled: self.source == .shoot)
    private var textController = StoryTextEditController()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryClose"), for: .normal)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        button.enableShadow()
        return button
    } ()
    
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryEdit"), for: .normal)
        button.setTitle("编辑", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: -15, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 13, left: -33, bottom: -23, right: 0)
        button.addTarget(self, action: #selector(didPressEditButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var pokeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "StoryPoke"), for: .normal)
        button.setTitle("戳住", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 12)
        button.imageEdgeInsets = UIEdgeInsets(top: -14, left: 8, bottom: 0, right: 0)
        button.titleEdgeInsets = UIEdgeInsets(top: 13, left: -33, bottom: -23, right: 0)
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
    private let user: User
    
    init(user: User, fileURL: URL, isPhoto: Bool, source: StoryMediaSource, topic: String?) {
        self.user = user
        self.fileURL = fileURL
        self.isPhoto = isPhoto
        self.topic = topic
        self.source = source
        textController.topic = topic
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.hero.modifiers = [.backgroundColor(.black)]
        add(childViewController: previewController)
        view.addSubview(editContainerView)
        if UIScreen.isNotched() {
            editContainerView.align(.top, to: view, inset: UIScreen.safeTopMargin())
            editContainerView.centerX(to: view)
            editContainerView.constrain(width: view.bounds.width, height: view.bounds.width * (16.0/9))
            editContainerView.clipsToBounds = true
            editContainerView.layer.cornerRadius = 7
            previewController.view.clipsToBounds = true
            previewController.view.layer.cornerRadius = 7
        } else {
            editContainerView.fill(in: view)
        }
        add(childViewController: textController, addView: false)
        editContainerView.addSubview(textController.view)
        previewController.view.fill(in: editContainerView)
        textController.view.fill(in: editContainerView)
        textController.delegate = self
        setupPokeView()
        setupControlButtons()
        textController.topic = topic
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        if Defaults[.isStoryFilterGuideShown] == false {
            Guide.showSwipeTip("划动屏幕切换滤镜")
            Defaults[.isStoryFilterGuideShown] = true
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        previewController.stopPreview()
    }
    
    // MARK: - Private
    
    private func setupControlButtons() {
        view.addSubview(closeButton)
        closeButton.constrain(width: 50, height: 50)
        closeButton.align(.right, to: editContainerView, inset: 10)
        closeButton.align(.top, to: editContainerView, inset: 10)
        view.addSubview(editButton)
        editButton.constrain(width: 50, height: 50)
        editButton.align(.left, to: view, inset: 10)
        if UIScreen.isNotched() {
            editButton.pin(.bottom, to: editContainerView, spacing: 10)
        } else {
            editButton.align(.bottom, to: view, inset: 25)
        }
        view.addSubview(pokeButton)
        pokeButton.equal(.size, to: editButton)
        pokeButton.centerY(to: editButton)
        pokeButton.pin(.right, to: editButton, spacing: 15)
        view.addSubview(finishButton)
        finishButton.constrain(width: 50, height: 50)
        finishButton.centerY(to: editButton)
        finishButton.align(.right, to: view, inset: 10)
        view.addSubview(deleteButton)
        deleteButton.constrain(width: 84, height: 84)
        if UIScreen.isNotched() {
            deleteButton.align(.bottom, to: editContainerView, inset: 10)
        } else {
            deleteButton.centerY(to: editButton)
        }
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
        editContainerView.addSubview(pokeView)
        pokeView.constrain(width: 120, height: 120)
        pokeCenterX = pokeView.centerX(to: editContainerView)
        pokeCenterY = pokeView.centerY(to: editContainerView)
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
        if isPhoto && textController.hasText == false && textController.topic == nil {
            onCancelled?()
            return
        }
        cancelEditing { self.onCancelled?() }
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
        editContainerView.clipsToBounds = false
        let isPokeHidden = pokeView.isHidden
        pokeView.isHidden = true
        let image = editContainerView.screenshot(afterScreenUpdates: true)
        pokeView.isHidden = isPokeHidden
        editContainerView.clipsToBounds = true
        
        let filterName = previewController.currentFilterName()
        let overlayFilename = image?.writeToCache(withAlpha: true)?.lastPathComponent
        if isPhoto {
            var draft = StoryDraft(filename: fileURL.lastPathComponent, storyType: .image, date: Date())
            draft.topic = topic
            draft.overlayFilename = overlayFilename
            draft.filterFilename = filterName
            draft.touchPoints = textController.makeTouchArea()
            finish(with: draft)
        } else {
            var pokeCenter: CGPoint?
            let type: StoryType
            if !self.pokeView.isHidden {
                type = .poke
                let editWidth = self.editContainerView.bounds.width
                let editHeight = self.editContainerView.bounds.height
                let centerX = (self.pokeView.center.x - editWidth / 2) / editWidth
                let centerY = (self.pokeView.center.y - editHeight / 2) / editHeight
                pokeCenter = CGPoint(
                    x: min(max(centerX, -0.5), 0.5),
                    y: min(max(centerY, -0.5), 0.5)
                )
            } else {
                type = .video
            }
            var draft = StoryDraft(filename: fileURL.lastPathComponent, storyType: type, date: Date())
            draft.topic = topic
            draft.pokeCenter = pokeCenter
            draft.touchPoints = textController.makeTouchArea()
            draft.overlayFilename = overlayFilename
            draft.filterFilename = filterName
            finish(with: draft)
        }
    }

    private func finish(with draft: StoryDraft) {
        let task = StoryPublishTask(storage: Storage(userID: user.userId), draft: draft)
        if !UIDevice.current.hasLessThan2GBRAM {
            task.finishBlock = { _ in
                NotificationCenter.default.post(name: .storyDidPublish, object: nil)
            }
        }
        TaskRunner.shared.run(task)
        
        if UIDevice.current.hasLessThan2GBRAM {
            HUD.show(.progress)
            task.completionBlock = { [weak self] in
                DispatchQueue.main.async { self?.complete() }
            }
        } else {
            complete()
        }
    }
    
    private func complete() {
        HUD.hide(animated: true)
        previewController.view.hero.id = "avatar"
        Defaults[.isPersonalStoryChecked] = false
        NotificationCenter.default.post(
            name: .avatarFakeImageUpdate,
            object: previewController.view.screenshot(afterScreenUpdates: true)
        )
        onFinished?()
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
        self.topic = topic
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.finishButton.alpha = 1
            self.closeButton.alpha = 1
            if self.isPhoto == false && self.pokeView.isHidden { self.pokeButton.alpha = 1 }
            self.editButton.alpha = self.textController.hasText ? 0 : 1
        }, completion: nil)
    }
}
