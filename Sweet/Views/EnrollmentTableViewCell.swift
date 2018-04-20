//
//  EnrollmentTableViewCell.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/4/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EnrollmentTableViewCell: UITableViewCell {

    private lazy var contentLabel: UILabel = {
        let contentLabel = UILabel()
        contentLabel.textColor = .black
        contentLabel.font = UIFont.systemFont(ofSize: 17)
        contentLabel.textAlignment = .center
        return contentLabel
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
        contentLabel.center(to: contentView)
        
    }
    
    func updateWithText(_ text: String) {
        contentLabel.text = text
    }
}
