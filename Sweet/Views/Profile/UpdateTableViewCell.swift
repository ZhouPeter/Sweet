//
//  UpdateTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateTableViewCell: UITableViewCell {
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 13)
        label.textAlignment = .left
        label.textColor = .black
        return label
    }()
    
    private lazy var enterImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "Artboard")
        return imageView
    }()
    
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .black
        return label
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.isHidden = true
        return imageView
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
        contentView.addSubview(titleLabel)
        titleLabel.centerY(to: contentView)
        titleLabel.align(.left, to: contentView, inset: 10)
        contentView.addSubview(enterImageView)
        enterImageView.constrain(width: 20, height: 20)
        enterImageView.centerY(to: contentView)
        enterImageView.align(.right, to: contentView)
        contentView.addSubview(contentLabel)
        contentLabel.centerY(to: contentView)
        contentLabel.pin(.left, to: enterImageView, spacing: 10)
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 40, height: 40)
        avatarImageView.pin(.left, to: enterImageView, spacing: 10)
        avatarImageView.centerY(to: contentView)
        avatarImageView.setViewRounded()
        
    }
    
    func update(viewModel: UpdateCellViewModel) {
        titleLabel.text = viewModel.title
        if viewModel.title == "头像" {
            avatarImageView.isHidden = false
            avatarImageView.kf.setImage(with: URL(string: viewModel.content)!)
        } else {
            avatarImageView.isHidden = true
            contentLabel.text = viewModel.content
        }
    }
}
