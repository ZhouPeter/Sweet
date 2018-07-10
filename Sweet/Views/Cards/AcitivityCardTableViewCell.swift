//
//  AcitivityCardTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class AcitivityCardTableViewCell: UITableViewCell {

    private var viewModel: ActivityCardViewModel?
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    private lazy var sameImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
        
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var resultTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    
    private lazy var emojiImageView = UIImageView()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.numberOfLines = 2
        return label
    }()
    private lazy var contentBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xf2f2f2)
        view.layer.cornerRadius = 5
        return view
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Unlike"), for: .normal)
        button.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return button
    }()
    
    func update(like: Bool) {
        likeButton.setImage(like ? #imageLiteral(resourceName: "Like") : #imageLiteral(resourceName: "Unlike"), for: .normal)
        viewModel?.like = like
    }
    
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
        avatarImageView.align(.left, inset: 10)
        avatarImageView.align(.top, inset: 10)
        avatarImageView.constrain(width: 20, height: 20)
        avatarImageView.setViewRounded()
        contentView.addSubview(sameImageView)
        sameImageView.align(.left, inset: 20)
        sameImageView.centerY(to: avatarImageView)
        sameImageView.constrain(width: 20, height: 20)
        sameImageView.setViewRounded()
        contentView.addSubview(titleLabel)
        titleLabel.centerY(to: avatarImageView)
        titleLabel.pin(.right, to: sameImageView, spacing: 8)
        let constraint = titleLabel.leftAnchor.constraint(equalTo: sameImageView.rightAnchor, constant: 8)
        constraint.priority = .defaultHigh
        constraint.isActive = true
        contentView.addSubview(subtitleLabel)
        subtitleLabel.centerY(to: avatarImageView)
        subtitleLabel.pin(.right, to: titleLabel, spacing: 4)
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.align(.left, inset: 10)
        contentBackgroundView.align(.right, inset: 10)
        contentBackgroundView.pin(.bottom, to: avatarImageView, spacing: 7)
        contentBackgroundView.constrain(height: 40)
        contentBackgroundView.addSubview(contentLabel)
        contentLabel.align(.left, inset: 6)
        contentLabel.align(.right, inset: 6)
        contentLabel.align(.top, inset: 6)
        contentView.addSubview(resultTitleLabel)
        resultTitleLabel.align(.left, to: avatarImageView)
        resultTitleLabel.pin(.bottom, to: contentBackgroundView, spacing: 7)
        contentView.addSubview(emojiImageView)
        emojiImageView.centerY(to: resultTitleLabel)
        emojiImageView.constrain(width: 24, height: 24)
        emojiImageView.pin(.right, to: resultTitleLabel, spacing: 1)
        contentView.addSubview(commentLabel)
        commentLabel.centerY(to: resultTitleLabel)
        commentLabel.pin(.right, to: resultTitleLabel, spacing: 6)
        contentView.addSubview(likeButton)
        likeButton.constrain(width: 30, height: 30)
        likeButton.align(.right, inset: 10)
        likeButton.pin(.bottom, to: contentBackgroundView)
    }
    
    func update(_ viewModel: ActivityCardViewModel) {
        self.viewModel = viewModel
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        sameImageView.kf.setImage(with: viewModel.sameAvatarURL)
        sameImageView.isHidden = viewModel.sameAvatarURL == nil
        titleLabel.text = viewModel.titleString
        subtitleLabel.text = viewModel.subtitleString
        commentLabel.text = viewModel.commentString
        if viewModel.commentString == "" {
            resultTitleLabel.text = "表示了"
        } else {
            resultTitleLabel.text = "选择了"
        }
        emojiImageView.image = viewModel.emojiImage
        contentLabel.attributedText = viewModel.contentAttributedString
        likeButton.setImage(viewModel.like ? #imageLiteral(resourceName: "Like") : #imageLiteral(resourceName: "Unlike"), for: .normal)
        likeButton.isHidden = viewModel.isHiddenLikeButton
    }
}


extension AcitivityCardTableViewCell {
    @objc private func likeAction(_ sender: UIButton) {
        if let viewModel = viewModel, !viewModel.like {
            viewModel.callBack?(viewModel.activityId)
        }
    }
}
