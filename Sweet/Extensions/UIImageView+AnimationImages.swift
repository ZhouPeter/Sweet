//
//  UIImageView+AnimationImages.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Kingfisher

//extension UIImageView {
//    func setAnimationImages(url: URL, animationDuration: TimeInterval, count: Int, size: CGSize) {
//        var urls = [URL]()
//        let urlString = url.absoluteString
//        for index in 0 ..< count {
//            let time = 0.5 / Double(count) * Double(index + 1)
//            let width = Int(size.width)
//            let height = Int(size.height)
//            let urlString = urlString + "?vframe/jpg/offset/\(time)/w/\(width)/h/\(height)"
//            let url = URL(string: urlString)!
//            urls.append(url)
//        }
//        self.image = nil
//        var images = [UIImage]()
//        let queue = DispatchQueue.global()
//        let group = DispatchGroup()
//        urls.forEach { (url) in
//            group.enter()
//            queue.async {
//                KingfisherManager.shared.retrieveImage(
//                    with: url,
//                    options: nil,
//                    progressBlock: nil,
//                    completionHandler: { (image, _, _, _) in
//                        group.leave()
//                        if let image = image {
//                            images.append(image)
//                        }
//                })
//            }
//            group.notify(queue: DispatchQueue.main) {
//                self.stopAnimating()
//                self.animationImages = images
//                self.animationDuration = animationDuration
//                self.startAnimating()
//            }
//        }
//    }
//}
extension UIImageView {
    func setAnimationImages(url: URL, animationDuration: TimeInterval, count: Int, size: CGSize) {
        var urls = [URL]()
        let urlString = url.absoluteString
        for index in 0 ..< count {
            let time = 0.5 / Double(count) * Double(index + 1)
            let width = Int(size.width)
            let height = Int(size.height)
            let urlString = urlString + "?vframe/jpg/offset/\(time)/w/\(width)/h/\(height)"
            let url = URL(string: urlString)!
            urls.append(url)
        }
        kf.setImage(with: urls[0])
        self.animationDuration = animationDuration
        for (index, url) in urls.enumerated() {
            KingfisherManager.shared.retrieveImage(
                with: url,
                options: nil,
                progressBlock: nil,
                completionHandler: { (image, _, _, imageURL) in
                    DispatchQueue.main.async {
                        self.stopAnimating()
                        guard let image = image else { return }
                        var currentImages = self.animationImages ?? [UIImage]()
                        while currentImages.count <= index {
                            currentImages.append(image)
                        }
                        currentImages[index] = image
                        self.animationImages = currentImages
                        self.layoutIfNeeded()
                        self.startAnimating()
                    }
            })
        }
    }
}

extension UIImageView {
    func playAnimation(images: [UIImage]) {
        var cgImages = [CGImage]()
        images.forEach { cgImages.append( $0.cgImage! ) }
        let animation = CAKeyframeAnimation(keyPath: "contents")
        animation.calculationMode = kCAAnimationDiscrete
        animation.keyTimes = [1.0 / 3, 2.0 / 3, 1] as [NSNumber]
        animation.duration = 0.5
        animation.values = cgImages
        animation.repeatCount = Float.greatestFiniteMagnitude
        animation.isRemovedOnCompletion = false
        animation.fillMode = kCAFillModeForwards
        animation.delegate = self
        self.layer.add(animation, forKey: "animation")
    }
}

extension UIImageView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        logger.debug(flag)
    }
}
