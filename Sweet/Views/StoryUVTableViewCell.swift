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
        layer.cornerRadius = 5
        layer.masksToBounds = true
    }
    
    override var frame: CGRect {
        didSet {
            var newFrame = frame
            newFrame.origin.x = StoryUVTableViewCell.marginX
            newFrame.origin.y += StoryUVTableViewCell.marginY
            newFrame.size.width -= newFrame.origin.x * 2
            newFrame.size.height -= StoryUVTableViewCell.marginY * 2
            super.frame = newFrame
        }
    }
    
    private func setupUI() {
        contentView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        contentView.addSubview(avatarImageView)
        avatarImageView.centerY(to: contentView)
        avatarImageView.align(.left, to: contentView, inset: 10)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.setViewRounded()
        contentView.addSubview(nicknameLabel)
        nicknameLabel.pin(.right, to: avatarImageView, spacing: 10)
        nicknameLabel.align(.top, to: avatarImageView)
        contentView.addSubview(infoLabel)
        infoLabel.align(.left, to: nicknameLabel)
        infoLabel.align(.bottom, to: avatarImageView)
        contentView.addSubview(likeImageView)
        likeImageView.constrain(width: 20, height: 20)
        likeImageView.centerY(to: contentView)
        likeImageView.align(.right, to: contentView, inset: 20)
    }
    
    
    
    

}
