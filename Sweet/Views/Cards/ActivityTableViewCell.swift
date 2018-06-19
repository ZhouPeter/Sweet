//
//  ActivityCardTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ActivityTableViewCell: UITableViewCell {
    private var viewModel: ActivityViewModel?

    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var leftAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var rightAvatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .black
        return label
    }()
    private lazy var emojiImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.numberOfLines = 3
        return label
    }()
    
    private lazy var likeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Unlike"), for: .normal)
        button.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        return button
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
        avatarImageView.constrain(width: 50, height: 50)
        avatarImageView.align(.left, to: contentView, inset: 10)
        avatarImageView.align(.top, to: contentView, inset: 20)
        avatarImageView.setViewRounded()
        avatarImageView.addSubview(leftAvatarImageView)
        leftAvatarImageView.constrain(width: 25, height: 50)
        leftAvatarImageView.align(.left)
        leftAvatarImageView.align(.top)
        leftAvatarImageView.setViewRounded(cornerRadius: 25, corners: [.topLeft, .bottomLeft])
        avatarImageView.addSubview(rightAvatarImageView)
        rightAvatarImageView.constrain(width: 25, height: 50)
        rightAvatarImageView.align(.right)
        rightAvatarImageView.align(.top)
        rightAvatarImageView.setViewRounded(cornerRadius: 25, corners: [.topRight, .bottomRight])
        contentView.addSubview(titleLabel)
        titleLabel.pin(.right, to: avatarImageView, spacing: 10)
        titleLabel.align(.top, to: avatarImageView)
        contentView.addSubview(subtitleLabel)
        subtitleLabel.pin(.right, to: titleLabel, spacing: 3)
        subtitleLabel.centerY(to: titleLabel)
        contentView.addSubview(commentLabel)
        commentLabel.align(.left, to: titleLabel)
        commentLabel.align(.bottom, to: avatarImageView)
        contentView.addSubview(contentLabel)
        contentLabel.align(.left, to: titleLabel)
        contentLabel.pin(.bottom, to: commentLabel, spacing: 7)
        contentLabel.align(.right, to: contentView, inset: 50)
        contentView.addSubview(likeButton)
        likeButton.constrain(width: 30, height: 30)
        likeButton.align(.right, to: contentView, inset: 10)
        likeButton.centerY(to: avatarImageView)
        likeButton.pin(.right, to: commentLabel, spacing: 10)

    }
    
    func update(_ viewModel: ActivityViewModel) {
        self.viewModel = viewModel
        if let leftAvatarURL = viewModel.leftAvatarURL, let rightAvatarURL = viewModel.rightAvatarURL {
            leftAvatarImageView.kf.setImage(with: leftAvatarURL)
            rightAvatarImageView.kf.setImage(with: rightAvatarURL)
            avatarImageView.image = nil
        } else {
            avatarImageView.kf.setImage(with: viewModel.avatarURL)
            leftAvatarImageView.image = nil
            rightAvatarImageView.image = nil
        }
        titleLabel.text = viewModel.titleString
        subtitleLabel.text = viewModel.subtitleString
        commentLabel.text = viewModel.commentString
        emojiImageView.image = viewModel.emojiImage
        contentLabel.text = viewModel.contentString
        if viewModel.like {
            likeButton.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "Unlike"), for: .normal)
        }
        likeButton.isHidden = viewModel.isHiddenLikeButton
    }
    
    func update(like: Bool) {
        if like {
            likeButton.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "Unlike"), for: .normal)
        }
        viewModel?.like = like
    }
    
    @objc private func likeAction(_ sender: UIButton) {
        if let viewModel = viewModel {
            if !viewModel.like {
                viewModel.callBack?(viewModel.activityId)
            }
        }
    }
    
}
