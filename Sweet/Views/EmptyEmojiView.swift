//
//  EmptyEmojiView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EmptyEmojiView: UIView {

    lazy var emojiImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor(hex: 0x9b9b9b)
        label.textAlignment = .center
        return label
    }()
    
    init(image: UIImage? = nil, title: String = "") {
        super.init(frame: .zero)
        setupUI()
        titleLabel.text = title
        emojiImageView.image = image ?? #imageLiteral(resourceName: "EmptyEmoji")
    }
    
    func update(image: UIImage, title: String) {
        titleLabel.text = title
        emojiImageView.image = image 
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = UIColor(hex: 0xF2F2F2)
        addSubview(emojiImageView)
        emojiImageView.constrain(width: 120, height: 120)
        emojiImageView.centerX(to: self)
        emojiImageView.align(.top, to: self, inset: 120)
        addSubview(titleLabel)
        titleLabel.centerX(to: self)
        titleLabel.pin(.bottom, to: emojiImageView)
    }

}
