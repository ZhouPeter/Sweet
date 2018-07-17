//
//  WarningHeaderView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/17.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import UIKit

final class WarningHeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "Warning")
        addSubview(imageView)
        imageView.constrain(width: 24, height: 24)
        imageView.align(.left, to: self, inset: 24)
        imageView.centerY(to: self)
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = UIColor(hex: 0xB2B2B2)
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "当前未连接"
        addSubview(label)
        label.align(.left, to: self, inset: 67)
        label.centerY(to: self)
    }
}
