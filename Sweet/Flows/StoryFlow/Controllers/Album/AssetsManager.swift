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
            let fetchResult = PHAsset.fetchAssets(with: self.makeFetchOptions())
            if fetchResult.count > 0 {
                var assets = [PHAsset]()
                fetchResult.enumerateObjects({ object, _, _ in
                    assets.append(object)
                })
                DispatchQueue.main.async {
                    completion(assets)
                }
            }
        }
    }
    
    private static func makeFetchOptions() -> PHFetchOptions {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.predicate = NSPredicate(
            format: "mediaType == %d || (mediaType == %d && duration >= %f)",
            PHAssetMediaType.image.rawValue,
            PHAssetMediaType.video.rawValue,
            1.0
        )
        return fetchOptions
    }
    
    static func fetch() -> PHFetchResult<PHAsset>? {
        guard PHPhotoLibrary.authorizationStatus() == .authorized else { return nil }
        let result = PHAsset.fetchAssets(with: self.makeFetchOptions())
        return result
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
    
    static func resolveAssets(_ assets: [PHAsset], size: CGSize = CGSize(width: 720, height: 1280)) -> [UIImage] {
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
    
    static func resolveAVAsset(_ asset: PHAsset, completion: @escaping (URL?, TimeInterval?) -> Void) {
        let options: PHVideoRequestOptions = PHVideoRequestOptions()
        options.version = .original
        PHImageManager
            .default()
            .requestAVAsset(forVideo: asset, options: options, resultHandler: { (avAsset, _, _) in
                DispatchQueue.main.async {
                    if let urlAsset = avAsset as? AVURLAsset {
                        let duration = urlAsset.duration.seconds
                        let url = URL.videoCacheURL(withName: urlAsset.url.lastPathComponent)
                        if FileManager.default.fileExists(atPath: url.path) {
                            completion(url, duration)
                            return
                        }
                        do {
                            try FileManager.default.copyItem(at: urlAsset.url, to: url)
                            completion(url, duration)
                        } catch {
                            logger.error(error)
                            completion(nil, nil)
                        }
                    } else {
                        completion(nil, nil)
                    }
                }
            })
    }
}
