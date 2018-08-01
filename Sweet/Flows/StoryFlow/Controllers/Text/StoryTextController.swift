//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

final class StoryTextController: BaseViewController, StoryTextView, StoryEditCancellable {
    var presentable: UIViewController { return self }
    
    var onFinished: (() -> Void)?
    var onCancelled: (() -> Void)?
    
    var boundingRect: CGRect {
        return editController.boundingRect
    }
    override var prefersStatusBarHidden: Bool { return true }
    override var preferredStatusBarStyle: UIStatusBarStyle { return .lightContent }
    private var topic: String?
    private lazy var gradientView = GradientSwitchView()
    private var gradientIndex = 0
    private lazy var editController = StoryTextEditController()
    
    private lazy var editContainer: UIView = {
        let view = UIView()
        view.backgroundColor = .clear
        return view
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
    
    private lazy var finishButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryConfirm"), for: .normal)
        button.addTarget(self, action: #selector(didPressFinishButton), for: .touchUpInside)
        button.enableShadow()
        return button
    } ()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "StoryClose"), for: .normal)
        button.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        button.enableShadow()
        return button
    } ()
    private let user: User
    
    init(user: User, topic: String?) {
        self.topic = topic
        self.user = user
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        view.hero.modifiers = [.backgroundColor(.black)]
        view.addSubview(editContainer)
        if UIScreen.isIphoneX() {
            editContainer.align(.top, to: view, inset: UIScreen.safeTopMargin())
            editContainer.centerX(to: view)
            editContainer.constrain(width: view.bounds.width, height: view.bounds.width * (16.0/9))
            editContainer.clipsToBounds = true
            editContainer.layer.cornerRadius = 7
        } else {
            editContainer.fill(in: view)
        }
        setupGradientView()
        setupEditController()
        setupEditControls()
        finishButton.alpha = 0
        editController.topic = topic
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        editController.beginEditing()
    }
    
    // MARK: - Private
    
    private func setupGradientView() {
        editContainer.addSubview(gradientView)
        gradientView.fill(in: editContainer)
        gradientView.changeColors([UIColor(hex: 0x8FE1FF), UIColor(hex: 0x56BFFE)])
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
        view.addSubview(editButton)
        view.addSubview(finishButton)
        editButton.constrain(width: 50, height: 50)
        editButton.align(.left, to: view, inset: 10)
        finishButton.constrain(width: 50, height: 50)
        finishButton.align(.right, to: view, inset: 10)
        if UIScreen.isIphoneX() {
            editButton.pin(.bottom, to: editContainer, spacing: 10)
            finishButton.pin(.bottom, to: editContainer, spacing: 10)
        } else {
            editButton.align(.bottom, to: view, inset: 25)
            finishButton.align(.bottom, to: view, inset: 25)
        }
        view.addSubview(closeButton)
        closeButton.constrain(width: 50, height: 50)
        closeButton.align(.right, to: editContainer, inset: 10)
        closeButton.align(.top, to: editContainer, inset: 10)
    }
    
    // MARK: - Actions
    
    @objc private func didPressFinishButton() {
        finishButton.alpha = 0
        closeButton.alpha = 0
        editButton.alpha = 0
        editContainer.clipsToBounds = false
        var filename: String?
        let image = editContainer.screenshot(afterScreenUpdates: true)
        editContainer.clipsToBounds = true
        if let snap = image {
            filename = snap.writeToCache(withAlpha: true)?.lastPathComponent
        }
        guard let name = filename else {
            logger.error("filename is nil")
            return
        }
        var draft = StoryDraft(filename: name, storyType: .text, date: Date())
        draft.topic = topic
        draft.touchPoints = editController.makeTouchArea()
        TaskRunner.shared.run(StoryPublishTask(storage: Storage(userID: user.userId), draft: draft))
        Defaults[.isPersonalStoryChecked] = false
        view.hero.id = "avatar"
        NotificationCenter.default.post(name: .avatarFakeImageUpdate, object: image)
        onFinished?()
    }
    
    @objc private func didPressCloseButton() {
        guard editController.hasText || editController.topic != nil else {
            onCancelled?()
            return
        }
        cancelEditing {
            self.onCancelled?()
        }
    }
    
    @objc private func didPressEditButton() {
        editController.beginEditing()
    }
}

extension StoryTextController: StoryTextEditControllerDelegate {
    func storyTextEditControllerDidBeginEditing() {
        UIView.animate(withDuration: 0.25) {
            self.finishButton.alpha = 0
        }
    }
    
    func storyTextEidtControllerDidEndEditing() {
        UIView.animate(withDuration: 0.25) {
            self.editButton.alpha = self.editController.hasText ? 0 : 1
            self.finishButton.alpha = 1
        }
        if Defaults[.isTextStoryGuideShown] == false {
            Guide.showSwipeTip("划动屏幕切换底色")
            Defaults[.isTextStoryGuideShown] = true
        }
    }
    
    func storyTextEditControllerDidPan(_ pan: UIPanGestureRecognizer) {
        if case .ended = pan.state {
            let isLeft = pan.translation(in: pan.view).x < 0
            let colors = nextGradientColors(isNext: isLeft)
            gradientView.changeColors(colors, animated: true)
        }
    }
    
    func storyTextEditControllerDidBeginChooseTopic() {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.closeButton.alpha = 0
            self.editButton.alpha = 0
        }, completion: nil)
    }
    
    func storyTextEditControllerDidEndChooseTopic(_ topic: String?) {
        UIView.animate(withDuration: 0.25, delay: 0, options: [.curveEaseOut], animations: {
            self.closeButton.alpha = 1
            self.editButton.alpha = self.editController.hasText ? 0 : 1
        }, completion: nil)
    }
    
    private func nextGradientColors(isNext: Bool) -> [UIColor] {
        var index = gradientIndex
        if isNext {
            if index >= gradientColors.count - 1 {
                index = 0
            } else {
                index += 1
            }
        } else {
            if index <= 0 {
                index = gradientColors.count - 1
            } else {
                index -= 1
            }
        }
        gradientIndex = index
        return gradientColors[index]
    }
}

private let gradientColors = [
    [UIColor(hex: 0x8FE1FF), UIColor(hex: 0x56BFFE)],
    [UIColor(hex: 0xF5515F), UIColor(hex: 0x9F041B)],
    [UIColor(hex: 0xFAD961), UIColor(hex: 0xF76B1C)],
    [UIColor(hex: 0xF8E71C), UIColor(hex: 0xF8E71C)],
    [UIColor(hex: 0xB4EC51), UIColor(hex: 0x429321)],
    [UIColor(hex: 0x88F3E2), UIColor(hex: 0x88F3E2)],
    [UIColor(hex: 0x50E3C2), UIColor(hex: 0x50E3C2)],
    [UIColor(hex: 0x3023AE), UIColor(hex: 0xC86DD7)],
    [UIColor(hex: 0xFFFFFF), UIColor(hex: 0x000000)]
]
