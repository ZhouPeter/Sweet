//
//  StoryGenerator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import GPUImage

final class StoryGenerator {
    private var movie: GPUImageMovie?
    private var writer: GPUImageMovieWriter?
    
    func generateImage(with fileURL: URL, filter: LookupFilter, overlay: UIImage?, callback: @escaping (URL?) -> Void) {
        DispatchQueue.global().async {
            guard let image = UIImage(contentsOfFile: fileURL.path) else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            let picture = GPUImagePicture(image: image)
            picture?.addTarget(filter)
            picture?.processImage()
            filter.useNextFrameForImageCapture()
            guard let result = filter.imageFromCurrentFramebuffer() else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            picture?.removeAllTargets()
            var data: Data?
            if let overlay = overlay,
                let newImage = result.merged(overlay, backgroundColor: .black, size: StoryConfg.photoSize) {
                data = UIImageJPEGRepresentation(newImage, 0.8)
            } else {
                data = UIImageJPEGRepresentation(result, 0.8)
            }
            guard let imageData = data else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            do {
                let url = URL.photoCacheURL(withName: UUID().uuidString + ".jpg")
                try imageData.write(to: url)
                DispatchQueue.main.async { callback(url) }
            } catch {
                logger.error(error)
                DispatchQueue.main.async { callback(nil) }
            }
        }
    }
    
    func generateVideo(with fileURL: URL, filter: LookupFilter, overlay: UIImage, callback: @escaping (URL?) -> Void) {
        
    }
}
