//
//  EmptyEmojiView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EmptyEmojiView: UIView {

    private lazy var emojiImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "EmptyEmoji")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.text = "快去首页发现有趣的同学"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x9b9b9b)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: 0xF2F2F2)
        addSubview(emojiImageView)
        emojiImageView.constrain(width: 150, height: 150)
        emojiImageView.centerX(to: self)
        emojiImageView.align(.top, to: self, inset: 120)
        addSubview(titleLabel)
        titleLabel.centerX(to: self)
        titleLabel.pin(.bottom, to: emojiImageView)
    }

}
