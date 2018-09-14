//
//  ShareCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ShareCollectionViewCell: UICollectionViewCell {
    private lazy var iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.cornerRadius = 25
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(iconImageView)
        iconImageView.constrain(width: 50, height: 50)
        iconImageView.center(to: contentView)
    }
    
    func update(image: UIImage) {
        iconImageView.image = image
    }
}
