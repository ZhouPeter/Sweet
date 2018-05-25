//
//  TextColorButton.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TextColorButton: UIButton {
    var color = UIColor.white {
        didSet {
            colorLayer.backgroundColor = color.cgColor
        }
    }
    
    private var colorLayer = CALayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.addSublayer(layer)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
