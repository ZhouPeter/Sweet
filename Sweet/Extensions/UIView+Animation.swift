//
//  UIView+Animation.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIView {
    func shrinkAnimation() {
        shrinkAnimation(scale: 0.9, duration: 0.8, damping: 0.5)
    }
    
    func recoverAnimation() {
        recoverAnimation(duration: 0.8, damping: 0.5)
    }
    
    func shrinkAnimation(scale: CGFloat, duration: Double, damping: CGFloat) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = CGAffineTransform(scaleX: scale, y: scale)
        }, completion: nil)
    }
    
    func recoverAnimation(duration: Double, damping: CGFloat) {
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: damping,
                       initialSpringVelocity: 0,
                       options: .allowUserInteraction,
                       animations: {
                        self.transform = .identity
        }, completion: nil)
    }
}
