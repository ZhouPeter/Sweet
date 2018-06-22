//
//  ContactsFooterView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ContactsFooterView: UITableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.xpTextGray()
        label.textAlignment  = .center
        return label
    }()
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        contentView.backgroundColor = UIColor.clear
        contentView.addSubview(titleLabel)
        titleLabel.center(to: contentView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(title: String) {
        titleLabel.text = title
    }
}
