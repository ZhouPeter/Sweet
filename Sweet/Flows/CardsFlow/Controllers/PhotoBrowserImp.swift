//
//  PhotoBrowserImp.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import JXPhotoBrowser

class PhotoBrowserImp: PhotoBrowserDelegate {
    private var thumbnaiImageViews: [UIImageView]
    private var highImageViewURLs: [URL]

    init(thumbnaiImageViews: [UIImageView], highImageViewURLs: [URL]) {
        self.thumbnaiImageViews = thumbnaiImageViews
        self.highImageViewURLs = highImageViewURLs
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return thumbnaiImageViews[index].image
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return thumbnaiImageViews[index]
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        
        return highImageViewURLs[index]
    }
    
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return highImageViewURLs.count
    }
}
