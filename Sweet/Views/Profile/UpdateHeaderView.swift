//
//  UpdateHeaderView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateHeaderView: UITableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black.withAlphaComponent(0.3)
        label.font = UIFont.systemFont(ofSize: 13)
        label.backgroundColor = .clear
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.xpGray()
        contentView.addSubview(titleLabel)
        titleLabel.align(.left, to: contentView, inset: 10)
        titleLabel.centerY(to: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        titleLabel.text = title
    }

}
