//
//  UIImageView+AnimationImages.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Kingfisher

extension UIImageView {
    func setAnimationImages(url: URL, animationDuration: TimeInterval, count: Int) {
        var urls = [URL]()
        let urlString = url.absoluteString
        for index in 0 ..< count {
            let time = 0.5 / Double(count) * Double(index + 1)
            let width = Int(UIScreen.mainWidth() / 3)
            let height = Int(UIScreen.mainHeight() / 3)
            let urlString = urlString
                + "?vframe/jpg/offset/\(time)/w/\(width)/h/\(height)"
            let url = URL(string: urlString)!
            urls.append(url)
        }
        self.image = nil
        var images = [UIImage]()
        let queue = DispatchQueue.global()
        let group = DispatchGroup()
        urls.forEach { (url) in
            group.enter()
            queue.async {
                ImageDownloader.default.downloadImage(with: url) { (image, _, _, _) in
                    group.leave()
                    if let image = image {
                        images.append(image)
                    }
                }
            }
         
            group.notify(queue: DispatchQueue.main) {
//                let url = GIFImageMake.makeSaveGIF(gifName: url.lastPathComponent, images: images)
//                self.kf.setImage(with: url)
                self.stopAnimating()
                self.animationImages = images
                self.animationDuration = animationDuration
                logger.debug(self.isAnimating)
                self.startAnimating()
                logger.debug(self.isAnimating)
            }
        }
    }
}
