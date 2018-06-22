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
        
        for (index, url) in urls.enumerated() {
            ImageDownloader.default.downloadImage(
                with: url,
                completionHandler: { [weak self] (image, _, _, _) in
                    guard let `self` = self  else { return }
                    guard let image = image  else { return }
        
                    DispatchQueue.main.async {
                        self.stopAnimating()
                        var currentImages = self.animationImages ?? [UIImage]()
                        while currentImages.count <= index {
                            currentImages.append(image)
                        }
                        currentImages[index] = image
                        self.animationImages = currentImages
                        self.setNeedsLayout()
                        self.startAnimating()
                    }
            })
        }
    }
}
