//
//  UIImage+Resize.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

extension UIImage {
    func fixOrientation() -> UIImage? {
        if imageOrientation == .up {
            return self
        }
        guard let cgImage = cgImage else { return nil }
        guard let ctx = CGContext(data: nil,
                            width: Int(size.width),
                            height: Int(size.height),
                            bitsPerComponent: cgImage.bitsPerComponent,
                            bytesPerRow: 0,
                            space: cgImage.colorSpace!,
                            bitmapInfo: cgImage.bitmapInfo.rawValue) else { return nil }
        let transform: CGAffineTransform = transformforOrientation(newSize: size)
        ctx.concatenate(transform)
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.height, height: size.width))
        default:
            ctx.draw(cgImage, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        }
        guard let cgImg = ctx.makeImage() else {return nil }
        let img = UIImage(cgImage: cgImg)
        return img
    }
    
    func transformforOrientation(newSize: CGSize) -> CGAffineTransform {
        var transform: CGAffineTransform = .identity
        switch imageOrientation {
        case .down,     // EXIF = 3
        .downMirrored:  // EXIF = 4
            transform = transform.translatedBy(x: newSize.width, y: newSize.height)
            transform = transform.rotated(by: .pi)
        case .left,     // EXIF = 6
        .leftMirrored:  // EXIF = 5
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.rotated(by: .pi/2)
        case .right,     // EXIF = 8
        .rightMirrored:  // EXIF = 7
            transform = transform.translatedBy(x: 0, y: newSize.height)
            transform = transform.rotated(by: -.pi/2)
        default:
            break
        }
        switch imageOrientation {
        case .upMirrored,   // EXIF = 2
        .downMirrored:      // EXIF = 4
            transform = transform.translatedBy(x: newSize.width, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        case .leftMirrored, // EXIF = 5
        .rightMirrored:     // EXIF = 7
            transform = transform.translatedBy(x: newSize.height, y: 0)
            transform = transform.scaledBy(x: -1, y: 1)
        default:
            break
        }
        return transform
    }
    
    // swiftlint:disable function_body_length
    func thumbnail(withSize size: CGSize) -> UIImage? {
        guard let newImage = fixOrientation() else { return nil }
        let originalSize = newImage.size
        if originalSize.width < size.width && originalSize.height < size.height {
            return newImage
        } else if originalSize.width > size.width && originalSize.height > originalSize.height {
            guard let newCgImage = newImage.cgImage else { return nil }
            var rate: CGFloat = 1.0
            let widthRate = originalSize.width / size.width
            let heightRate = originalSize.height / size.height
            rate = widthRate > heightRate ? heightRate : widthRate
            var image: CGImage? = nil
            if heightRate > widthRate {
                image = newCgImage.cropping(
                    to: CGRect(x: 0,
                               y: originalSize.height / 2 - size.height * rate / 2,
                               width: originalSize.width,
                               height: size.height * rate))
                //获取图片整体部分
            } else {
                image = newCgImage.cropping(
                    to: CGRect(x: originalSize.width / 2 - size.width * rate / 2,
                               y: 0,
                               width: size.width * rate,
                               height: originalSize.height))
                //获取图片整体部分
            }
            UIGraphicsBeginImageContext(size)
            guard let cxt = UIGraphicsGetCurrentContext() else { return nil }
            let transform = newImage.transformforOrientation(newSize: size)
            cxt.concatenate(transform)
            cxt.translateBy(x: 0.0, y: size.height)
            cxt.scaleBy(x: 1.0, y: -1.0)
            cxt.draw(image!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let standardImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return standardImage
        } else if originalSize.height > size.height || originalSize.width > size.width {
            guard let newCgImage = newImage.cgImage else { return nil }
            var image: CGImage? = nil
            if originalSize.height > size.height {
                image = newCgImage.cropping(
                    to: CGRect(x: 0,
                            y: originalSize.height / 2 - size.height / 2,
                            width: originalSize.width,
                            height: size.height))
            } else {
                image = newCgImage.cropping(
                    to: CGRect(x: originalSize.width / 2 - size.width / 2,
                               y: 0,
                               width: size.width,
                               height: originalSize.height))
            }
            UIGraphicsBeginImageContext(size)
            guard let cxt = UIGraphicsGetCurrentContext() else { return nil }
            cxt.translateBy(x: 0.0, y: size.height)
            cxt.scaleBy(x: 1.0, y: -1.0)
            cxt.draw(image!, in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
            let standardImage: UIImage? = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            return standardImage
        } else {
            return newImage
        }
    }
    
    func resize(newSize: CGSize) -> UIImage {
        UIGraphicsBeginImageContext(newSize)
        draw(in: CGRect(origin: .zero, size: newSize))
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }
    
    func resize(newSize: CGSize, interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        var drawTransposed = false
        switch imageOrientation {
        case .left, .leftMirrored, .right, .rightMirrored:
            drawTransposed = true
        default:
            drawTransposed = false
        }
        let transform = transformforOrientation(newSize: newSize)
        return resize(newSize: newSize,
                      transform: transform,
                      drawTransposed: drawTransposed,
                      interpolationQuality: quality)
    }
    
    private func resize(newSize: CGSize,
                        transform: CGAffineTransform,
                        drawTransposed transpose: Bool,
                        interpolationQuality quality: CGInterpolationQuality) -> UIImage {
        let scale: CGFloat = max(1.0, self.scale)
        let newRect = CGRect(x: 0, y: 0, width: newSize.width * scale, height: newSize.height * scale).integral
        let transposedRect = CGRect(origin: .zero, size: newRect.size)
        let cgImg = cgImage
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmap = CGContext(data: nil,
                               width: Int(newRect.size.width),
                               height: Int(newRect.size.height),
                               bitsPerComponent: 8,
                               bytesPerRow: Int(newRect.size.width) * 4,
                               space: colorSpace,
                               bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue)
        
        bitmap?.concatenate(transform)
        bitmap?.interpolationQuality = quality
        bitmap?.draw(cgImg!, in: transpose ? transposedRect : newRect)
        let newCgImage = bitmap?.makeImage()
        let newImage = UIImage(cgImage: newCgImage!, scale: scale, orientation: .up)
        return newImage
    }
    
    func scaleAndCropImage(toSize size: CGSize) -> UIImage {
        guard !self.size.equalTo(size) else { return self }
        
        let widthFactor = size.width / self.size.width
        let heightFactor = size.height / self.size.height
        var scaleFactor: CGFloat = 0.0
        
        scaleFactor = heightFactor
        if widthFactor > heightFactor {
            scaleFactor = widthFactor
        }
        
        var targetOrigin = CGPoint.zero
        let scaledWidth  = self.size.width * scaleFactor
        let scaledHeight = self.size.height * scaleFactor
        
        if widthFactor > heightFactor {
            targetOrigin.y = (size.height - scaledHeight) / 2.0
        } else if widthFactor < heightFactor {
            targetOrigin.x = (size.width - scaledWidth) / 2.0
        }
        
        var targetRect = CGRect.zero
        targetRect.origin = targetOrigin
        targetRect.size.width  = scaledWidth
        targetRect.size.height = scaledHeight
        
        UIGraphicsBeginImageContextWithOptions(size, false, 0.0)
        draw(in: targetRect)
        let scaledImage = UIGraphicsGetImageFromCurrentImageContext()!
        UIGraphicsEndImageContext()
        
        return scaledImage
    }
}
