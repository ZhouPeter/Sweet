//
//  StoryUVTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class StoryUVTableViewCell: UITableViewCell {
    static let marginX: CGFloat = 10
    static let marginY: CGFloat = 1
    
    private lazy var blackMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var nicknameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = UIColor.white.withAlphaComponent(0.5)
        return label
    }()
    
    private lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "HeartRed")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        layer.cornerRadius = 5
        layer.masksToBounds = true
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        selectionStyle = .none
        contentView.backgroundColor = .clear
        blackMaskView.layer.cornerRadius = 5
    
    }
    
    private func setupUI() {
        contentView.addSubview(blackMaskView)
        blackMaskView.fill(in: contentView,left: 10, right: 10, top: 1, bottom: 1)
        blackMaskView.addSubview(avatarImageView)
        avatarImageView.centerY(to: blackMaskView)
        avatarImageView.align(.left, to: blackMaskView, inset: 10)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.setViewRounded()
        blackMaskView.addSubview(nicknameLabel)
        nicknameLabel.pin(.right, to: avatarImageView, spacing: 10)
        nicknameLabel.align(.top, to: avatarImageView)
        blackMaskView.addSubview(infoLabel)
        infoLabel.align(.left, to: nicknameLabel)
        infoLabel.align(.bottom, to: avatarImageView)
        blackMaskView.addSubview(likeImageView)
        likeImageView.constrain(width: 20, height: 20)
        likeImageView.centerY(to: blackMaskView)
        likeImageView.align(.right, to: blackMaskView, inset: 20)
    }
    
    func update(_ model: StoryUvInfo) {
        avatarImageView.kf.setImage(with:URL(string: model.avatar)!)
        nicknameLabel.text = model.nickname
        infoLabel.text = model.info
        likeImageView.isHidden = !model.like
    }


}
