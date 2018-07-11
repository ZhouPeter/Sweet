//
//  PhotoBrowserImp.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import JXPhotoBrowser
import PKHUD

class PhotoBrowserImp: NSObject, PhotoBrowserDelegate {
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
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        showAlertSheet(photoBrowser: photoBrowser, image: image)
    }
    
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return highImageViewURLs.count
    }
    
    private func showAlertSheet(photoBrowser: PhotoBrowser, image: UIImage) {
        let alert = UIAlertController()
        let shareAction = UIAlertAction.makeAlertAction(title: "分享给联系人", style: .default) { (_) in
            
        }
        let downloadAction = UIAlertAction.makeAlertAction(title: "保存到手机", style: .default) { (_) in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(shareAction)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        photoBrowser.present(alert, animated: true, completion: nil)
    }
    
    @objc func image(_ image: UIImage?,
                             didFinishSavingWithError error: Error?,
                             contextInfo: UnsafeMutableRawPointer?) {
        if error == nil {
            PKHUD.toast(message: "保存成功")
        } else {
            PKHUD.toast(message: "保存失败")
        }
    }
}

class AvatarPhotoBrowserImp: PhotoBrowserImp {
    
    override func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        showAlertSheet(photoBrowser: photoBrowser, image: image)
    }
    
    private func showAlertSheet(photoBrowser: PhotoBrowser, image: UIImage) {
        let alert = UIAlertController()
        let downloadAction = UIAlertAction.makeAlertAction(title: "保存到手机", style: .default) { (_) in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        photoBrowser.present(alert, animated: true, completion: nil)
    }

}
