//
//  UIView+Round.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIView {
    func drawRect(cornerRadius: CGFloat,
                  borderWidth: CGFloat,
                  backgroundColor: UIColor,
                  borderColor: UIColor) -> UIImage {
        let sizeToFit = CGSize(width: bounds.width, height: bounds.height)
        let halfBorderWidth = borderWidth / 2
        UIGraphicsBeginImageContextWithOptions(sizeToFit, false, UIScreen.main.scale)
        let context = UIGraphicsGetCurrentContext()
        if borderWidth > 0 {
            context?.setLineWidth(borderWidth)
            context?.setStrokeColor(borderColor.cgColor)
        }
        context?.setFillColor(backgroundColor.cgColor)
        let width = sizeToFit.width
        let height = sizeToFit.height
        context?.move(to: CGPoint(x: width - halfBorderWidth,
                                  y: cornerRadius + halfBorderWidth))
        context?.addArc(tangent1End: CGPoint(x: width - halfBorderWidth,
                                             y: height - halfBorderWidth),
                        tangent2End: CGPoint(x: width - cornerRadius - halfBorderWidth,
                                             y: height - cornerRadius - halfBorderWidth),
                        radius: cornerRadius)
        context?.addArc(tangent1End: CGPoint(x: halfBorderWidth,
                                             y: height - halfBorderWidth),
                        tangent2End: CGPoint(x: halfBorderWidth,
                                             y: height - cornerRadius - halfBorderWidth),
                        radius: cornerRadius)
        context?.addArc(tangent1End: CGPoint(x: halfBorderWidth,
                                             y: halfBorderWidth),
                        tangent2End: CGPoint(x: width - halfBorderWidth,
                                             y: halfBorderWidth),
                        radius: cornerRadius)
        context?.addArc(tangent1End: CGPoint(x: width - halfBorderWidth,
                                             y: halfBorderWidth),
                        tangent2End: CGPoint(x: width - halfBorderWidth,
                                             y: cornerRadius + halfBorderWidth),
                        radius: cornerRadius)
        context?.drawPath(using: .fillStroke)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image!
    }
    
    func setView(cornerRadius: CGFloat, borderWidth: CGFloat, borderColor: UIColor) {
        layoutIfNeeded()
        let maskPath = UIBezierPath(roundedRect: bounds, cornerRadius: cornerRadius)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.path = maskPath.cgPath
        layer.mask = maskLayer
        if borderWidth > 0 {
            let borderLayer = CAShapeLayer()
            let halfWidth = borderWidth / 2
            let frame = CGRect(x: halfWidth,
                               y: halfWidth,
                               width: bounds.width - borderWidth,
                               height: bounds.height - borderWidth)
            borderLayer.path = UIBezierPath(roundedRect: frame, cornerRadius: cornerRadius).cgPath
            borderLayer.fillColor = UIColor.clear.cgColor
            borderLayer.strokeColor = borderColor.cgColor
            borderLayer.lineWidth = borderWidth
            borderLayer.frame = CGRect(origin: .zero, size: frame.size)
            layer.addSublayer(borderLayer)
        }
    }
    
    func setViewRounded(borderWidth: CGFloat, borderColor: UIColor) {
        layoutIfNeeded()
        let cornerRadius = bounds.height / 2
        setView(cornerRadius: cornerRadius, borderWidth: borderWidth, borderColor: borderColor)
    }
    
    func setViewRounded() {
        layoutIfNeeded()
        let cornerRadius = bounds.height / 2
        setView(cornerRadius: cornerRadius, borderWidth: 0, borderColor: .clear)
    }
}
