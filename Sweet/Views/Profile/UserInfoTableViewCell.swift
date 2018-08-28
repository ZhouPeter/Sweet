//
//  UserInfoTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol UserInfoTableViewCellDelegate: class {
    func didPressAvatarImageView(_ imageView: UIImageView, highURL: URL)
    func editSignature()
}
class UserInfoTableViewCell: UITableViewCell {
    weak var delegate: UserInfoTableViewCellDelegate?
    private var viewModel: BaseInfoCellViewModel?
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressAvatar(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        return label
    }()
    
    private lazy var heartImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Star")
        return imageView
    }()
    private lazy var starContactLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        return label
    }()
    private lazy var segmentLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    private lazy var collegeInfoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textAlignment = .center
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        return label
    }()
    private lazy var signatureLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black.withAlphaComponent(0.65)
        return label
    }()
    private lazy var editButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Edit"), for: .normal)
        button.contentHorizontalAlignment = .right
        button.addTarget(self, action: #selector(didPressEdit(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var bottomMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        return view
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(avatarImageView)
        avatarImageView.centerX(to: contentView)
        avatarImageView.align(.top, inset: 15)
        avatarImageView.constrain(width: 80, height: 80)
        avatarImageView.setViewRounded()
        contentView.addSubview(nicknameLabel)
        nicknameLabel.centerX(to: avatarImageView)
        nicknameLabel.pin(.bottom, to: avatarImageView, spacing: 10)
        contentView.addSubview(starContactLabel)
        starContactLabel.pin(.bottom, to: nicknameLabel, spacing: 8)
        starContactLabel.centerX(to: avatarImageView, offset: 14)
        contentView.addSubview(heartImageView)
        heartImageView.centerY(to: starContactLabel)
        heartImageView.constrain(width: 24, height: 24)
        heartImageView.pin(.left, to: starContactLabel, spacing: 4)
        contentView.addSubview(segmentLineView)
        segmentLineView.align(.left)
        segmentLineView.align(.right)
        segmentLineView.constrain(height: 0.5)
        segmentLineView.pin(.bottom, to: heartImageView, spacing: 10)
        contentView.addSubview(collegeInfoLabel)
        collegeInfoLabel.align(.left, inset: 10)
        collegeInfoLabel.align(.right, inset: 10)
        collegeInfoLabel.pin(.bottom, to: segmentLineView, spacing: 10)
        contentView.addSubview(signatureLabel)
        signatureLabel.centerX(to: avatarImageView)
        signatureLabel.pin(.bottom, to: collegeInfoLabel, spacing: 10)
        contentView.addSubview(editButton)
        editButton.fill(in: signatureLabel, right: -18)
        contentView.addSubview(bottomMaskView)
        bottomMaskView.align(.left)
        bottomMaskView.align(.right)
        bottomMaskView.align(.bottom)
        bottomMaskView.constrain(height: 8)
    }

    func updateWith(_ viewModel: BaseInfoCellViewModel) {
        self.viewModel = viewModel
        avatarImageView.kf.setImage(with: viewModel.avatarImageURL)
        nicknameLabel.attributedText = viewModel.nicknameSexAttributedString
        starContactLabel.text = viewModel.starContactString
        collegeInfoLabel.text = viewModel.collegeInfoString
        signatureLabel.text = viewModel.signatureString
        editButton.isHidden = viewModel.isHiddenEdit
    }
    
    @objc private func didPressAvatar(_ tap: UITapGestureRecognizer) {
        delegate?.didPressAvatarImageView(avatarImageView, highURL: viewModel!.avatarImageURL)
    }
    
    @objc private func didPressEdit(_ sender: UIButton) {
        delegate?.editSignature()
    }
}
