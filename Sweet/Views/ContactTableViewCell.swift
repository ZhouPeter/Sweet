//
//  ContactTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContactTableViewCell: UITableViewCell {

    private var buttonCallBack: ((String) -> Void)?
    private var userId: UInt64?
    private var sectionId: UInt64?
    private var phone: String?
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
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
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.xpTextGray()
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var statusButton: UIButton = {
        let button = UIButton()
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 14
        button.layer.masksToBounds = true
        button.isHidden = true
        button.addTarget(self, action: #selector(statusAction(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var selectButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(#imageLiteral(resourceName: "ContactSelected"), for: .selected)
        button.setBackgroundImage(#imageLiteral(resourceName: "ContactUnSelected"), for: .normal)
        button.isHidden = true
        button.isUserInteractionEnabled = false
        return button
    }()
    
    private var nameCenterYConstraints: NSLayoutConstraint?
    private var avatarImageViewMaskLayer: CAShapeLayer?
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func statusAction(_ sender: UIButton) {
        if let userId = userId, let buttonCallBack = buttonCallBack {
            buttonCallBack("\(userId)")
        } else if let sectionId = sectionId, let buttonCallBack = buttonCallBack {
            buttonCallBack("\(sectionId)")
        } else if let phone = phone, let buttonCallBack = buttonCallBack {
            buttonCallBack(phone)
        }
    }
    private var infoRightConstaint: NSLayoutConstraint?
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.centerY(to: contentView)
        avatarImageView.align(.left, to: contentView, inset: 16)
        avatarImageViewMaskLayer = avatarImageView.setViewRounded().maskLayer
        avatarImageView.addSubview(avatarLabel)
        avatarLabel.fill(in: avatarImageView)
        contentView.addSubview(nameLabel)
        nameLabel.align(.left, to: contentView, inset: 66)
        nameCenterYConstraints = nameLabel.centerYAnchor.constraint(
            equalTo: avatarImageView.centerYAnchor, constant: -10)
        nameCenterYConstraints?.isActive = true
        contentView.addSubview(infoLabel)
        infoLabel.align(.left, to: nameLabel)
        infoLabel.align(.bottom, to: avatarImageView)
        infoRightConstaint = infoLabel.align(.right, to: contentView, inset: 16)
        contentView.addSubview(statusButton)
        statusButton.constrain(width: 62, height: 28)
        statusButton.centerY(to: contentView)
        statusButton.align(.right, to: contentView, inset: 10)
        contentView.addSubview(selectButton)
        selectButton.constrain(width: 22, height: 22)
        selectButton.centerY(to: contentView)
        selectButton.align(.right, inset: 12)
    }
    
    func update(viewModel: ContactViewModel) {
        userId = viewModel.userId
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        avatarImageView.layer.mask = avatarImageViewMaskLayer
        avatarLabel.text = ""
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        selectButton.isHidden = viewModel.isHiddeenSelectButton
        if !viewModel.isHiddenButton {
            statusButton.setTitle(viewModel.buttonTitle, for: .normal)
            statusButton.setButtonStyle(style: viewModel.buttonStyle!)
        }
        nameCenterYConstraints?.constant = -10
        buttonCallBack = viewModel.callBack
        infoRightConstaint?.constant = statusButton.isHidden ? -16 : -(10 + 62)
    }
    
    func updateCategroy(viewModel: ContactCategoryViewModel) {
        avatarImageView.image = viewModel.categoryImage
        avatarImageViewMaskLayer?.removeFromSuperlayer()
        nameLabel.text = viewModel.title
        infoLabel.text = ""
        avatarLabel.text = ""
        statusButton.isHidden = true
        buttonCallBack = nil
        nameCenterYConstraints?.constant = 0
        infoRightConstaint?.constant = statusButton.isHidden ? -16 : -(10 + 62)
    }
    
    func updatePhoneContact(viewModel: PhoneContactViewModel) {
        phone = viewModel.phone
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        avatarImageView.layer.mask = avatarImageViewMaskLayer
        avatarLabel.text = viewModel.firstNameString
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        statusButton.isUserInteractionEnabled = viewModel.buttonIsEnabled
        statusButton.setTitle(viewModel.buttonTitle, for: .normal)
        statusButton.setButtonStyle(style: viewModel.buttonStyle)
        nameCenterYConstraints?.constant = viewModel.nameCenterYOffsetAvatar
        buttonCallBack = viewModel.callBack
        infoRightConstaint?.constant = statusButton.isHidden ? -16 : -(10 + 62)
    }
    
    func updateSectionWithButton(viewModel: ContactSubcriptionSectionViewModel) {
        sectionId = viewModel.sectionId
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        avatarImageView.setViewRounded(cornerRadius: 5, corners: .allCorners)
        avatarLabel.text = ""
        nameLabel.text = viewModel.nameString
        infoLabel.text = viewModel.infoString
        statusButton.isHidden = viewModel.isHiddenButton
        statusButton.setTitle(viewModel.buttonTitle, for: .normal)
        statusButton.setButtonStyle(style: viewModel.buttonStyle)
        buttonCallBack = viewModel.callBack
        infoRightConstaint?.constant = statusButton.isHidden ? -16 : -(10 + 62)
    }
}
