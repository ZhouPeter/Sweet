//
//  AcitivityCardTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage

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
        label.textColor = .black
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
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = UIColor.black.withAlphaComponent(0.8)
        return label
    }()
    
    private lazy var emojiImageView = UIImageView()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.numberOfLines = 2
        label.baselineAdjustment = .alignCenters
        return label
    } ()
    
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
    
    private var titleLabelLeft: NSLayoutConstraint?
    
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
        titleLabelLeft = titleLabel.pin(.right, to: sameImageView, spacing: 8)
        contentView.addSubview(subtitleLabel)
        subtitleLabel.centerY(to: avatarImageView)
        subtitleLabel.pin(.right, to: titleLabel, spacing: 4)
        subtitleLabel.align(.right, inset: 10)
        contentView.addSubview(contentBackgroundView)
        contentBackgroundView.align(.left, inset: 10)
        contentBackgroundView.align(.right, inset: 10)
        contentBackgroundView.pin(.bottom, to: avatarImageView, spacing: 10)
        contentBackgroundView.constrain(height: 40)
        contentBackgroundView.addSubview(contentLabel)
        contentLabel.fill(in: contentBackgroundView, left: 8, right: 6, top: 0, bottom: 0)
        contentView.addSubview(resultTitleLabel)
        resultTitleLabel.align(.left, to: avatarImageView, inset: 3)
        resultTitleLabel.pin(.bottom, to: contentBackgroundView, spacing: 14)
        contentView.addSubview(emojiImageView)
        emojiImageView.centerY(to: resultTitleLabel)
        emojiImageView.constrain(width: 30, height: 30)
        emojiImageView.pin(.right, to: resultTitleLabel, spacing: 1)
        contentView.addSubview(commentLabel)
        commentLabel.centerY(to: resultTitleLabel)
        commentLabel.pin(.right, to: resultTitleLabel, spacing: 3)
        contentView.addSubview(likeButton)
        likeButton.constrain(width: 28, height: 28)
        likeButton.align(.right, inset: 12)
        likeButton.centerY(to: resultTitleLabel)
    }
    
    func update(_ viewModel: ActivityCardViewModel) {
        self.viewModel = viewModel
        avatarImageView.sd_setImage(with: viewModel.avatarURL)
        if viewModel.sameAvatarURL == nil {
            sameImageView.isHidden = true
            titleLabelLeft?.constant = -3
        } else {
            sameImageView.isHidden = false
            sameImageView.sd_setImage(with: viewModel.avatarURL)
            titleLabelLeft?.constant = 8
        }
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
