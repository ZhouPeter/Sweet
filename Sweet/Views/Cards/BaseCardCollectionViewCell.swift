//
//  CardBaseCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BaseCardCollectionViewCell: UICollectionViewCell {
    private lazy var rounderRectView: RoundedRectView = {
        let view = RoundedRectView()
        view.isShadowEnabled = true
        view.shadowInsetX = 10
        view.shadowInsetY = 10
        view.cornerRadius = 10
        view.shadowOpacity = 0.3
        return view
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 15)
        label.textColor = UIColor.black.withAlphaComponent(0.5)
        label.text = "大家都在看"
        return label
    }()
    
    lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Menu_black").withRenderingMode(.alwaysTemplate), for: .normal)
        button.tintColor = UIColor(hex: 0x9b9b9b)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBaseUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupBaseUI() {
//        contentView.addSubview(rounderRectView)
//        rounderRectView.frame = contentView.frame
        layer.shadowOpacity = 0.3
        layer.shadowRadius = 10
        contentView.addSubview(titleLabel)
        titleLabel.align(.left, to: contentView, inset: 20)
        titleLabel.align(.top, to: contentView, inset: 25)
        contentView.addSubview(menuButton)
        menuButton.centerY(to: titleLabel)
        menuButton.align(.right, to: contentView, inset: 20)
        menuButton.constrain(width: 30, height: 30)
    }
}
