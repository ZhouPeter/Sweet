//
//  SDWebImagePhotoLoader.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import JXPhotoBrowser
import SDWebImage
class SDWebImagePhotoLoader: PhotoLoader {
    func isImageCached(on imageView: UIImageView, url: URL) -> Bool {
        let cacheKey = SDWebImageManager.shared.cacheKey(for: url)
        if SDImageCache.shared.imageFromCache(forKey: cacheKey) == nil {
            return false
        } else {
            return true
        }
    }
    
    func setImage(on imageView: UIImageView,
                  url: URL?,
                  placeholder: UIImage?,
                  progressBlock: @escaping (Int64, Int64) -> Void,
                  completionHandler: @escaping () -> Void) {
        imageView.sd_setImage(with: url,
                              placeholderImage: placeholder,
                              options: [],
                              progress: { (receivedSize, totalSize, _) in
            progressBlock(Int64(receivedSize), Int64(totalSize))
        }) { (_, _, _, _) in
            completionHandler()
        }
    }
}
