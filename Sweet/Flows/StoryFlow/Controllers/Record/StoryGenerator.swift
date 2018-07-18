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
        logger.debug(fileURL)
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
    
    func generateVideo(with fileURL: URL, filter: LookupFilter, overlay: UIImage?, callback: @escaping (URL?) -> Void) {
        logger.debug(fileURL)
        movie = GPUImageMovie(url: fileURL)
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        writer = GPUImageMovieWriter(movieURL: url, size: StoryConfg.videoSize)
        writer?.shouldPassthroughAudio = true
        movie?.audioEncodingTarget = writer
        movie?.enableSynchronizedEncoding(using: writer)
        movie?.addTarget(filter)
        let imageView = UIImageView(image: overlay)
        let uiElement = GPUImageUIElement(view: imageView)
        filter.frameProcessingCompletionBlock = { _, time in uiElement?.update(withTimestamp: time) }
        let blendFilter = GPUImageAlphaBlendFilter()
        blendFilter.mix = 1
        filter.addTarget(blendFilter)
        uiElement?.addTarget(blendFilter)
        blendFilter.addTarget(writer)
        writer?.startRecording()
        movie?.startProcessing()
        let clean: () -> Void = { [weak self] in
            blendFilter.removeAllTargets()
            filter.removeAllTargets()
            uiElement?.removeAllTargets()
            self?.movie?.removeAllTargets()
            self?.movie?.audioEncodingTarget = nil
        }
        writer?.completionBlock = { [weak self] in
            self?.writer?.finishRecording()
            clean()
            DispatchQueue.main.async { callback(url) }
        }
        writer?.failureBlock = { error in
            logger.error(error ?? "")
            clean()
            DispatchQueue.main.async { callback(nil) }
        }
    }
}
