//
//  NotiRankingCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class NotiRankingCollectionViewCell: UICollectionViewCell {
    private lazy var indexLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .white
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    private lazy var likeImageView: UIImageView =  UIImageView(image: UIImage(named: "Like"))
    
    private lazy var likeCountLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.backgroundColor = UIColor.white.withAlphaComponent(0.35)
        contentView.layer.cornerRadius = 5
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(indexLabel)
        indexLabel.align(.left, inset: 10)
        indexLabel.centerY(to: contentView)
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.align(.left, inset: 40)
        avatarImageView.centerY(to: contentView)
        avatarImageView.setViewRounded(borderWidth: 1, borderColor: .white)
        contentView.addSubview(nameLabel)
        nameLabel.pin(.right, to: avatarImageView, spacing: 10)
        nameLabel.align(.top, to: avatarImageView)
        contentView.addSubview(commentLabel)
        commentLabel.align(.left, to: nameLabel)
        commentLabel.align(.bottom, to: avatarImageView)
        contentView.addSubview(likeImageView)
        likeImageView.constrain(width: 20, height: 20)
        likeImageView.align(.right, inset: 15)
        likeImageView.centerY(to: contentView)
        contentView.addSubview(likeCountLabel)
        likeCountLabel.pin(.left, to: likeImageView, spacing: 3)
        likeCountLabel.centerY(to: likeImageView)
    }
    
    func update (viewModel: LikeRankViewModel) {
        indexLabel.text = "\(viewModel.index)"
        avatarImageView.sd_setImage(with: viewModel.avatarURL)
        nameLabel.text = viewModel.nameString
        commentLabel.text = viewModel.commentString
        likeCountLabel.text = "\(viewModel.likeCount)"
    }
}
