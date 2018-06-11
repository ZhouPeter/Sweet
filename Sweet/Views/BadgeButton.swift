//
//  UIView+Badge.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class BadgeButton: UIButton {
    let rightSpacing: CGFloat = -4
    let badgeWidth: CGFloat = 7
    private lazy var badgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hex: 0xF43530)
        return label
    }()
    
    private lazy var countBadgeLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor(hex: 0xF43530)
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 15)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func hiddenBadge() {
        badgeLabel.isHidden = true
        countBadgeLabel.isHidden = true
    }
    
    func showBadge() {
        let badgeFrame = CGRect(x: frame.width + rightSpacing,
                                y: -badgeWidth / 2,
                                width: badgeWidth,
                                height: badgeWidth)
        badgeLabel.frame = badgeFrame
        badgeLabel.layer.cornerRadius = badgeWidth / 2
        badgeLabel.layer.masksToBounds = true
        addSubview(badgeLabel)
        bringSubview(toFront: badgeLabel)
        badgeLabel.isHidden = false
        countBadgeLabel.isHidden = true
    }
    
    func showCountBadge(text: String) {
        addSubview(countBadgeLabel)
        bringSubview(toFront: countBadgeLabel)
        countBadgeLabel.fill(in: self)
        countBadgeLabel.layoutIfNeeded()
        countBadgeLabel.setViewRounded()
        badgeLabel.isHidden = true
        countBadgeLabel.isHidden = false
        countBadgeLabel.text = text
    }
}
