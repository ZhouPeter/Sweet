//
//  EvaluationTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EvaluationTableViewCell: UITableViewCell {

    private lazy var leftImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 5
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = .black
        return label
    }()
    
    private lazy var likeImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.selectionStyle = .none
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(leftImageView)
        leftImageView.constrain(width: 40, height: 40)
        leftImageView.centerY(to: contentView)
        leftImageView.align(.left, inset: 10)
        contentView.addSubview(titleLabel)
        titleLabel.centerY(to: leftImageView)
        titleLabel.pin(.right, to: leftImageView, spacing: 10)
        contentView.addSubview(likeImageView)
        likeImageView.centerY(to: leftImageView)
        likeImageView.constrain(width: 30, height: 30)
        likeImageView.align(.right, inset: 10)
    }
    
    func update(model: EvaluationResponse) {
        leftImageView.kf.setImage(with: URL(string: model.image))
        titleLabel.text = model.text
        likeImageView.image = model.like ? #imageLiteral(resourceName: "Like") : #imageLiteral(resourceName: "Unlike")
        
    }
    
}
