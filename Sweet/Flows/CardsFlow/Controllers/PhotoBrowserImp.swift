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
import SwiftyUserDefaults
import Photos
import MobileCoreServices
import SDWebImage
class CustomPhotoBrowser: PhotoBrowser {
    private var backButton: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "Return"), for: .normal)
        return button
    }()
    
    @objc private func backAction(_ sender: UIButton) {
        dismiss(animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(backButton)
        backButton.frame = CGRect(x: 0, y: UIScreen.safeTopMargin() +  20, width: 30, height: 30)
        
    }
}
class PhotoBrowserImp: NSObject, PhotoBrowserDelegate {
    private var thumbnaiImageViews: [UIImageView]?
    private var shareText: String?
    var highImageViewURLs: [URL]
    init(thumbnaiImageViews: [UIImageView]? = nil, highImageViewURLs: [URL], shareText: String? = nil) {
        self.thumbnaiImageViews = thumbnaiImageViews
        self.highImageViewURLs = highImageViewURLs
        self.shareText = shareText
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailImageForIndex index: Int) -> UIImage? {
        return thumbnaiImageViews?[index].image
    }

    func photoBrowser(_ photoBrowser: PhotoBrowser, thumbnailViewForIndex index: Int) -> UIView? {
        return thumbnaiImageViews?[index]
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, highQualityUrlForIndex index: Int) -> URL? {
        return highImageViewURLs[index]
    }
    
    func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        showAlertSheet(photoBrowser: photoBrowser, image: image, url: highImageViewURLs[index].absoluteString)
    }
    
    func numberOfPhotos(in photoBrowser: PhotoBrowser) -> Int {
        return highImageViewURLs.count
    }
    
    private func showAlertSheet(photoBrowser: PhotoBrowser, image: UIImage, url: String) {
        let alert = UIAlertController()
        let shareAction = UIAlertAction.makeAlertAction(title: "分享", style: .default) { [weak self] (_) in
            guard let `self` = self else { return }
            let controller = ShareCardController(shareText: self.shareText)
            controller.sendCallback = { (text, userIds) in
                self.sendImage(url: url, text: text, userIds: userIds)
            }
            photoBrowser.present(controller, animated: true, completion: nil)
        }
        let downloadAction = UIAlertAction.makeAlertAction(title: "保存到手机", style: .default) { (_) in
            self.saveImage(url: url)
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(shareAction)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        photoBrowser.present(alert, animated: true, completion: nil)
        
    }

    private func sendImage(url: String, text: String, userIds: [UInt64]) {
        if let IDString = Defaults[.userID], let from = UInt64(IDString) {
            userIds.forEach {
                Messenger.shared.sendImage(with: url, from: from, to:  $0)
                if text != "" { Messenger.shared.sendText(text, from: from, to: $0) }
            }
        }
        NotificationCenter.default.post(name: .dismissShareCard, object: nil)
    }
}

extension PhotoBrowserImp {
    func saveImage(url: String) {
        PHPhotoLibrary.shared().performChanges({
            let cacheKey = SDWebImageManager.shared.cacheKey(for: URL(string: url))
            guard let cachePath = SDImageCache.shared.cachePath(forKey: cacheKey) else { return }
            let fileURL = URL(fileURLWithPath: cachePath)
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: fileURL.path) else { return }
            guard let data = try? Data(contentsOf: fileURL) else { return }
            PHAssetCreationRequest.forAsset().addResource(with: .photo, data: data, options: nil)
        }, completionHandler: { (success, error) in
            DispatchQueue.main.async {
                if error == nil {
                    PKHUD.toast(message: "保存成功")
                } else {
                    PKHUD.toast(message: "保存失败")
                }
            }
        })
    }
}

class AvatarPhotoBrowserImp: PhotoBrowserImp {
    
    override func photoBrowser(_ photoBrowser: PhotoBrowser, didLongPressForIndex index: Int, image: UIImage) {
        showAlertSheet(photoBrowser: photoBrowser, image: image, url: highImageViewURLs[index].absoluteString)
    }
    
    private func showAlertSheet(photoBrowser: PhotoBrowser, image: UIImage, url: String) {
        let alert = UIAlertController()
        let downloadAction = UIAlertAction.makeAlertAction(title: "保存到手机", style: .default) { (_) in
            self.saveImage(url: url)
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alert.addAction(downloadAction)
        alert.addAction(cancelAction)
        photoBrowser.present(alert, animated: true, completion: nil)
    }

}
