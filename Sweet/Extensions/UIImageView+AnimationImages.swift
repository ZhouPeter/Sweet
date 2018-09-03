//
//  UIImageView+AnimationImages.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SDWebImage
extension UIImageView {
    func setAnimationImages(withVideoURL url: URL,
                            animationDuration: TimeInterval,
                            count: Int,
                            size: CGSize) {
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
        sd_setImage(with: urls[0])
        self.animationDuration = animationDuration
        let prefetcher = SDWebImagePrefetcher.shared
        prefetcher.prefetchURLs(urls, progress: nil) { [weak self] (noOfFinishedUrls, noOfSkippedUrls) in
            guard noOfSkippedUrls == 0, let `self` = self else { return }
            self.animationImages = urls.compactMap({
                SDImageCache.shared.imageFromMemoryCache(forKey: prefetcher.manager.cacheKey(for: $0))
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
