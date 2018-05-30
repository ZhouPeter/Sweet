//
//  ContactCategoryTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContactCategoryTableViewCell: UITableViewCell {
    private lazy var categoryImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(categoryImageView)
        categoryImageView.constrain(width: 40, height: 40)
        categoryImageView.align(.left, to: contentView, inset: 10)
        categoryImageView.centerY(to: contentView)
        contentView.addSubview(titleLabel)
        titleLabel.centerY(to: categoryImageView)
        titleLabel.pin(.right, to: categoryImageView, spacing: 10)
    }
    
    func update(image: UIImage, title: String) {
        categoryImageView.image = image
        titleLabel.text = title
    }

}
