//
//  BadgeView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BadgeView: UIView {
    var text: String? {
        didSet {
            label.text = text
            invalidateIntrinsicContentSize()
        }
    }
    
    private let label: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 13)
        return label
    } ()
    
    private let cornerRadius: CGFloat
    
    init(cornerRadius: CGFloat) {
        self.cornerRadius = cornerRadius
        super.init(frame: .zero)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        clipsToBounds = true
        backgroundColor = UIColor(hex: 0xfa001d)
        addSubview(label)
        label.fill(in: self)
        layer.cornerRadius = cornerRadius
    }
    
    override var intrinsicContentSize: CGSize {
        let size = label.intrinsicContentSize
        var width = cornerRadius * 2
        if let count = label.text?.count, count > 1 {
            width = max(size.width + cornerRadius, cornerRadius * 2)
        }
        return CGSize(width: width, height: cornerRadius * 2)
    }
}
