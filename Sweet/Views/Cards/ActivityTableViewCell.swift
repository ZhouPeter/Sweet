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
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 0
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
        contentView.addSubview(titleLabel)
        titleLabel.pin(.right, to: avatarImageView, spacing: 10)
        titleLabel.align(.top, to: avatarImageView)
        contentView.addSubview(subtitleLabel)
        subtitleLabel.pin(.right, to: titleLabel, spacing: 10)
        subtitleLabel.centerY(to: titleLabel)
        contentView.addSubview(contentLabel)
        contentLabel.align(.left, to: titleLabel)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 10)
        contentLabel.align(.right, to: contentView, inset: 50)
        contentView.addSubview(likeButton)
        likeButton.constrain(width: 30, height: 30)
        likeButton.align(.right, to: contentView, inset: 10)
        likeButton.centerY(to: contentView)
    }
    
    func update(_ viewModel: ActivityViewModel) {
        self.viewModel = viewModel
        avatarImageView.kf.setImage(with: viewModel.avatarURL)
        titleLabel.text = viewModel.titleString
        subtitleLabel.text = viewModel.subtitleString
        contentLabel.text = viewModel.contentString
        if viewModel.like {
            likeButton.setImage(#imageLiteral(resourceName: "Like"), for: .normal)
        } else {
            likeButton.setImage(#imageLiteral(resourceName: "Unlike"), for: .normal)
        }
    }
    
    @objc private func likeAction(_ sender: UIButton) {
        if let viewModel = viewModel {
            viewModel.callBack?(viewModel.activityItemId)
        }
    }
    
}