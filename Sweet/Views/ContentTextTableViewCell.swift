//
//  ContentTextTableViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContentTextTableViewCell: UITableViewCell {
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.xpTextGray()
        label.font = UIFont.systemFont(ofSize: 17)
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
        contentView.addSubview(contentLabel)
        contentLabel.align(.left, to: contentView, inset: 16)
        contentLabel.centerY(to: contentView)
    }
    
    func updateWithText(_ text: String) {
        contentLabel.text = text
    }
}
