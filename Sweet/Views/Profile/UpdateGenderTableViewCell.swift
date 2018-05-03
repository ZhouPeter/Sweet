//
//  UpdateGenderTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateGenderTableViewCell: UITableViewCell {
    private var sexLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    private var selectedImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Selected")
        return imageView
    }()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = .white
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(sexLabel)
        sexLabel.align(.left, to: contentView, inset: 10)
        sexLabel.centerY(to: contentView)
        contentView.addSubview(selectedImageView)
        selectedImageView.align(.right, to: contentView, inset: 10)
        selectedImageView.centerY(to: contentView)
        selectedImageView.constrain(width: 30, height: 30)
    }
    
    func update(text: String, isSelected: Bool) {
        sexLabel.text = text
        selectedImageView.isHidden = !isSelected
    }
    
}
