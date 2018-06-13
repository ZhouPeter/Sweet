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
            if text == nil {
                showDot(isDot: true)
            } else {
                showDot(isDot: false)
                label.text = text
            }
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
    
    private let dotView: UIImageView = {
        let view = UIImageView()
        view.image = #imageLiteral(resourceName: "RedDot")
        view.contentMode = .center
        return view
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
        addSubview(label)
        label.fill(in: self)
        layer.cornerRadius = cornerRadius
        addSubview(dotView)
        dotView.center(to: self)
        dotView.constrain(width: 7, height: 7)
        showDot(isDot: false)
    }
    
    private func showDot(isDot: Bool) {
        if isDot {
            dotView.alpha = 1
            label.alpha = 0
            backgroundColor = .clear
        } else {
            dotView.alpha = 0
            label.alpha = 1
            backgroundColor = UIColor(hex: 0xfa001d)
        }
    }
    
    override var intrinsicContentSize: CGSize {
        if label.text == nil {
            return CGSize(width: cornerRadius * 2, height: cornerRadius * 2)
        }
        let size = label.intrinsicContentSize
        var width = cornerRadius * 2
        if let count = label.text?.count, count > 1 {
            width = max(size.width + cornerRadius, cornerRadius * 2)
        }
        return CGSize(width: width, height: cornerRadius * 2)
    }
}
