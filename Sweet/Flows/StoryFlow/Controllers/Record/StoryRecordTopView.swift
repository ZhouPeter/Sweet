//
//  StoryRecordTopView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol StoryRecordTopViewDelegate: class {
    func topViewDidPressBackButton()
    func topViewDidPressFlashButton(isOn: Bool)
    func topViewDidPressCameraSwitchButton(isFront: Bool)
    func topViewDidPressAvatarButton()
}

final class StoryRecordTopView: UIView {
    weak var delegate: StoryRecordTopViewDelegate?
    
    private lazy var avatarButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "Avatar"), for: .normal)
        button.clipsToBounds = true
        button.layer.cornerRadius = 20
        button.layer.borderColor = UIColor.white.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(didPressAvatarButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var avatarCircle: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    } ()
    
    private lazy var cameraSwitchButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "CameraBack"), for: .normal)
        button.addTarget(self, action: #selector(didPressCameraSwitchButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var flashButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
        button.addTarget(self, action: #selector(didPressFlashButton), for: .touchUpInside)
        return button
    } ()
    
    private lazy var backButton: UIButton = {
        let button = UIButton(type: .custom)
        button.setImage(#imageLiteral(resourceName: "RightArrow"), for: .normal)
        button.addTarget(self, action: #selector(didPressBackButton), for: .touchUpInside)
        return button
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateAvatarCircle(isUnread: Bool) {
        avatarCircle.image = isUnread ? #imageLiteral(resourceName: "StoryUnread") : #imageLiteral(resourceName: "StoryRead")
    }
    
    // MARK: - Private
    
    private func setup() {
        addSubview(avatarButton)
        addSubview(avatarCircle)
        addSubview(cameraSwitchButton)
        addSubview(flashButton)
        addSubview(backButton)
        avatarButton.constrain(width: 40, height: 40)
        avatarButton.align(.left, to: self, inset: 10)
        avatarButton.centerY(to: self)
        avatarCircle.equal(.size, to: avatarButton)
        avatarCircle.center(to: avatarButton)
        cameraSwitchButton.centerY(to: self)
        cameraSwitchButton.centerX(to: self, offset: -30)
        cameraSwitchButton.constrain(width: 30, height: 30)
        flashButton.centerY(to: self)
        flashButton.centerX(to: self, offset: 30)
        flashButton.constrain(width: 30, height: 30)
        backButton.constrain(width: 30, height: 30)
        backButton.centerY(to: self)
        backButton.align(.right, to: self, inset: 5)
        updateAvatarCircle(isUnread: false)
    }
    
    @objc private func didPressAvatarButton() {
        delegate?.topViewDidPressAvatarButton()
    }
    
    @objc private func didPressCameraSwitchButton() {
        if cameraSwitchButton.isSelected {
            cameraSwitchButton.isSelected = false
            cameraSwitchButton.setImage(#imageLiteral(resourceName: "CameraBack"), for: .normal)
        } else {
            cameraSwitchButton.isSelected = true
            cameraSwitchButton.setImage(#imageLiteral(resourceName: "CameraFront"), for: .normal)
        }
        delegate?.topViewDidPressCameraSwitchButton(isFront: cameraSwitchButton.isSelected)
    }
    
    @objc private func didPressFlashButton() {
        if flashButton.isSelected {
            flashButton.isSelected = false
            flashButton.setImage(#imageLiteral(resourceName: "FlashOff"), for: .normal)
        } else {
            flashButton.isSelected = true
            flashButton.setImage(#imageLiteral(resourceName: "FlashOn"), for: .normal)
        }
        delegate?.topViewDidPressFlashButton(isOn: flashButton.isSelected)
    }
    
    @objc private func didPressBackButton() {
        delegate?.topViewDidPressBackButton()
    }
}
