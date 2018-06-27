//
//  RoundedRectView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class RoundedRectView: UIView {
    var fillColor: UIColor {
        didSet {
            foregroundLayer.fillColor = fillColor.cgColor
        }
    }
    var isShadowEnabled: Bool {
        didSet {
            setNeedsLayout()
        }
    }
    var shadowInsetX: CGFloat
    var shadowInsetY: CGFloat
    var shadowRadius: CGFloat
    var cornerRadius: CGFloat
    var shadowOpacity: CGFloat
    var shadowOffset: CGSize
    private var shadowLayer: CAShapeLayer
    private var foregroundLayer: CAShapeLayer
    
    override init(frame: CGRect) {
        fillColor = .white
        cornerRadius = 8
        shadowInsetX = 10
        shadowInsetY = 5
        shadowRadius = 5
        isShadowEnabled = false
        shadowOpacity = 0.15
        shadowOffset = CGSize.zero
        shadowLayer = CAShapeLayer()
        foregroundLayer = CAShapeLayer()
        super.init(frame: frame)
        layer.insertSublayer(shadowLayer, at: 0)
        layer.insertSublayer(foregroundLayer, at: 1)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        shadowLayer.path = UIBezierPath(
                     roundedRect: bounds.insetBy(dx: shadowInsetX, dy: shadowInsetY),
                     cornerRadius: cornerRadius).cgPath
        shadowLayer.fillColor = UIColor.white.cgColor
        shadowLayer.strokeColor = nil
        shadowLayer.frame = bounds
        foregroundLayer.fillColor = fillColor.cgColor
        foregroundLayer.frame = bounds
        if isShadowEnabled {
            if shadowLayer.superlayer == nil {
                layer.insertSublayer(shadowLayer, at: 0)
            }
            shadowLayer.shadowPath = shadowLayer.path
            shadowLayer.shadowOpacity = Float(shadowOpacity)
            shadowLayer.shadowRadius = shadowRadius
            shadowLayer.shadowOffset = shadowOffset
        } else {
            shadowLayer.shadowPath = nil
            shadowLayer.removeFromSuperlayer()
        }
        
    }
    
}
