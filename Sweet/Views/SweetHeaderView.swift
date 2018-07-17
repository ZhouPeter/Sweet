//
//  UpdateHeaderView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SweetHeaderView: UITableViewHeaderFooterView {

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.black.withAlphaComponent(0.3)
        label.font = UIFont.systemFont(ofSize: 12)
        label.backgroundColor = .clear
        return label
    }()
    
    init(frame: CGRect) {
        super.init(reuseIdentifier: "")
        setupUI()
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundView?.backgroundColor = .clear
        contentView.backgroundColor = .clear
        backgroundColor = .clear
        contentView.addSubview(titleLabel)
        titleLabel.align(.left, to: contentView, inset: 16)
        titleLabel.centerY(to: contentView)
    }

    func update(title: String) {
        titleLabel.text = title
    }
}
