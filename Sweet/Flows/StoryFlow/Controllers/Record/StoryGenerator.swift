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
        guard let track = AVAsset(url: fileURL).tracks(withMediaType: .video).first else {
            callback(nil)
            return
        }
        let videoSize = track.naturalSize.applying(track.preferredTransform)
        movie = GPUImageMovie(url: fileURL)
        
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        let renderSize = StoryConfg.videoSize
        writer = GPUImageMovieWriter(movieURL: url, size: renderSize)
        writer?.shouldPassthroughAudio = true
        movie?.audioEncodingTarget = writer
        movie?.enableSynchronizedEncoding(using: writer)
        
        let transformFilter = GPUImageTransformFilter()
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        let videoRatio = videoSize.width / videoSize.height
        let renderRatio = renderSize.width / renderSize.height
        if videoRatio > renderRatio {
            scaleY = videoSize.height / renderSize.height * (renderSize.width / videoSize.width)
        } else if (videoRatio < renderRatio) {
            scaleX = videoSize.width / renderSize.width * (renderSize.height / videoSize.height)
        }
        transformFilter.affineTransform = CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY)
        movie?.addTarget(transformFilter)
        transformFilter.addTarget(filter)
        
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
