//
//  StoryTextController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class StoryTextController: BaseViewController, StoryTextView {
    var onFinished: (() -> Void)?
    private var topic: String?
    private lazy var gradientView = GradientSwitchView()
    private lazy var editController = StoryTextEditController()
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientView()
        view.addSubview(editContainer)
        editContainer.fill(in: view)
        setupEditController()
        setupEditControls()
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
    
    @objc private func didPressNextButton() {
        
//        editController.endEditing()
//        hideEditControls(false, animated: true)
    }
    
    @objc private func didPressDeleteButton() {
        
    }
    
    @objc private func didPressConfirmButton() {
//        isPublishing = false
//        enablePageScroll = true
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
}
