//
//  UIImage+MessageBubble.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIImage {
    class func bubbleImage(named name: String, orientation: UIImageOrientation) -> UIImage? {
        guard var image = UIImage(named: name) else { return nil }
        guard let cgImage = image.cgImage else { return nil }
        image = UIImage(cgImage: cgImage, scale: image.scale, orientation: orientation)
        return image.stretchedBubbleImage()
    }
    
    func stretchedBubbleImage() -> UIImage {
        let center = CGPoint(x: size.width / 2, y: size.height / 2)
        let capInsets = UIEdgeInsets(top: center.y, left: center.x, bottom: center.y, right: center.x)
        return resizableImage(withCapInsets: capInsets, resizingMode: .stretch)
    }
}
