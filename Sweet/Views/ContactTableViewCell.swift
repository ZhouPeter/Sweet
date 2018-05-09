//
//  ContactTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    private var buttonCallBack: ((UInt64) -> Void)?
    private var userId: UInt64?
    private var sectionId: UInt64?
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: 0xf7f7f7)
        return imageView
    }()
    
    private lazy var avatarLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = UIColor.xpTextGray()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.xpTextGray()
        label.font = UIFont.systemFont(ofSize: 13)
        return label
    }()
    
    private lazy var statusButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(buttonAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private var nameCenterYConstraints: NSLayoutConstraint?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func buttonAction(_ sender: UIButton) {
        if let userId = userId, let buttonCallBack = buttonCallBack {
            buttonCallBack(userId)
        }
    }
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.centerY(to: contentView)
        avatarImageView.align(.left, to: contentView, inset: 15)
        avatarImageView.setViewRounded()
        avatarImageView.addSubview(avatarLabel)
        avatarLabel.fill(in: avatarImageView)
        contentView.addSubview(nameLabel)
        nameLabel.pin(to: avatarImageView, edge: .right, spacing: -10)
        nameCenterYConstraints = nameLabel.centerYAnchor.constraint(
            equalTo: avatarImageView.centerYAnchor, constant: -10)
        nameCenterYConstraints?.isActive = true
        contentView.addSubview(infoLabel)
        infoLabel.pin(to: avatarImageView, edge: .right, spacing: -10)
        infoLabel.align(.bottom, to: avatarImageView)
        contentView.addSubview(statusButton)
        statusButton.constrain(width: 62, height: 28)
        statusButton.centerY(to: contentView)
        statusButton.align(.right, to: contentView, inset: 14)
    }
    
    func update(viewModel: ContactViewModel) {
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
    }
    
    func updatePhoneContact(viewModel: PhoneContactViewModel) {
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        avatarLabel.text = viewModel.firstNameString
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        statusButton.setTitle(viewModel.buttonTitle, for: .normal)
        statusButton.setButtonStyle(style: viewModel.buttonStyle)
        nameCenterYConstraints?.constant = viewModel.nameCenterYOffsetAvatar
    }
    
    func updateContactWithButton(viewModel: ContactWithButtonViewModel) {
        userId = viewModel.userId
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        statusButton.setTitle(viewModel.buttonTitle, for: .normal)
        statusButton.setButtonStyle(style: viewModel.buttonStyle)
        buttonCallBack = viewModel.callBack
    }
    
    func updateSectionWithButton(viewModel: ContactSubcriptionSectionViewModel) {
        sectionId = viewModel.sectionId
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        statusButton.setTitle(viewModel.buttonTitle, for: .normal)
        statusButton.setButtonStyle(style: viewModel.buttonStyle)
        buttonCallBack = viewModel.callBack
    }
}
