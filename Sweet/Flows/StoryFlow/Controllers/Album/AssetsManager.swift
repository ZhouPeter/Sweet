//
//  AssetsManager.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import UIKit
import Photos

class AssetManager {
    static func fetch(completion: @escaping (_ assets: [PHAsset]) -> Void) {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return }
        
        DispatchQueue.global(qos: .background).async {
            let fetchResult = PHAsset.fetchAssets(with: .image, options: PHFetchOptions())
            if fetchResult.count > 0 {
                var assets = [PHAsset]()
                fetchResult.enumerateObjects({ object, _, _ in
                    assets.insert(object, at: 0)
                })
                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        }
    }
    
    static func resolveAsset(
        _ asset: PHAsset,
        size: CGSize = CGSize(width: 720, height: 1280),
        shouldPreferLowRes: Bool = false,
        completion: @escaping (_ image: UIImage?) -> Void) {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.deliveryMode = shouldPreferLowRes ? .fastFormat : .highQualityFormat
        requestOptions.isNetworkAccessAllowed = true
        
        imageManager.requestImage(
        for: asset,
        targetSize: size,
        contentMode: .aspectFill,
        options: requestOptions) { image, _ in
            DispatchQueue.main.async {
                completion(image)
            }
        }
    }
    
    open static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
        let imageManager = PHImageManager.default()
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        var images = [UIImage]()
        for asset in assets {
            imageManager.requestImage(
            for: asset,
            targetSize: size,
            contentMode: .aspectFill,
            options: requestOptions) { image, _ in
                if let image = image {
                    images.append(image)
                }
            }
        }
        return images
    }
}
