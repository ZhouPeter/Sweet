//
//  UIImage+Merge.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIImage {
    func merged(_ image: UIImage, backgroundColor: UIColor?, size: CGSize) -> UIImage? {
        guard let newImage = scaled(min(size.width / self.size.width, size.height / self.size.height)) else {
            return nil
        }
        UIGraphicsBeginImageContextWithOptions(size, false, 1)
        if let backgroundColor = backgroundColor {
            backgroundColor.set()
            UIRectFill(CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        newImage.draw(
            in: CGRect(
                x: (size.width - newImage.size.width) / 2,
                y: (size.height - newImage.size.height) / 2,
                width: newImage.size.width,
                height: newImage.size.height
            ),
            blendMode: .normal,
            alpha: 1.0
        )
        image.draw(
            in: CGRect(x: 0, y: 0, width: size.width, height: size.height),
            blendMode: .normal,
            alpha: 1.0
        )
        let result = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return result
    }
    
    public func scaled(_ scale: CGFloat) -> UIImage? {
        if scale == 1.0 { return self }
        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
    
    func addSlaveImage(slaveImage: UIImage) -> UIImage? {
        let bottomHeight = size.width * 160 / 750
        let newSize = CGSize(width: size.width, height: size.height + bottomHeight)
        UIGraphicsBeginImageContextWithOptions(newSize, true, 0)
        draw(in: CGRect(origin: .zero, size: size))
        slaveImage.draw(in: CGRect(x: 0, y: size.height, width: size.width, height: bottomHeight))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}
