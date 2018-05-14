//
//  TextTransform.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct TextTransform {
    var scale: CGFloat = 1
    var rotation: CGFloat = 0
    var translation = CGPoint.zero
    
    func make3DTransform() -> CATransform3D {
        var transform = CATransform3DIdentity
        transform = CATransform3DTranslate(transform, translation.x, translation.y, 0)
        transform = CATransform3DRotate(transform, rotation, 0, 0, 1)
        transform = CATransform3DScale(transform, scale, scale, 1)
        return transform
    }
    
    func makeCGAffineTransform() -> CGAffineTransform {
        return CGAffineTransform.identity
            .translatedBy(x: translation.x, y: translation.y)
            .rotated(by: rotation)
            .scaledBy(x: scale, y: scale)
    }
}
