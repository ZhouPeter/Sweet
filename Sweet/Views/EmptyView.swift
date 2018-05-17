//
//  EmptyView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EmptyView: UIView {
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "Sweat")
        return imageView
    }()
    
    lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.xpTextGray()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textAlignment = .center
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(imageView)
        imageView.constrain(width: 50, height: 50)
        imageView.centerX(to: self)
        imageView.align(.top, to: self, inset: 140)
        addSubview(titleLabel)
        titleLabel.pin(.bottom, to: imageView, spacing: 20)
        titleLabel.align(.left, to: self, inset: 10)
        titleLabel.align(.right, to: self, inset: 10)
        titleLabel.constrain(height: 40)
    }
    
}
