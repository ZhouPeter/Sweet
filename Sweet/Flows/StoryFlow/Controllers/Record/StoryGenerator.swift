//
//  StoryGenerator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import GPUImage
import AVFoundation

final class StoryGenerator {
    private var movie: GPUImageMovie?
    private var writer: GPUImageMovieWriter?
    private var pictrue: GPUImagePicture?
    
    func generateImage(with fileURL: URL, filter: LookupFilter, overlay: UIImage?, callback: @escaping (URL?) -> Void) {
        logger.debug(fileURL)
        DispatchQueue.global().async {
            guard let image = UIImage(contentsOfFile: fileURL.path) else {
                DispatchQueue.main.async { callback(nil) }
                return
            }
            let targetPicture = GPUImagePicture(image: image)
            self.pictrue = targetPicture
            targetPicture?.addTarget(filter)
            targetPicture?.processImage()
            filter.useNextFrameForImageCapture()
            guard let result = filter.imageFromCurrentFramebuffer() else {
                self.pictrue = nil
                DispatchQueue.main.async { callback(nil) }
                return
            }
            self.pictrue = nil
            targetPicture?.removeAllTargets()
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
    
    private var blendFilter: GPUImageAlphaBlendFilter?
    private var transformFilter: GPUImageTransformFilter?
    
    func generateVideo(with fileURL: URL, filter: LookupFilter, overlay: UIImage?, callback: @escaping (URL?) -> Void) {
        logger.debug(fileURL)
        let asset = AVAsset(url: fileURL)
        guard let track = asset.tracks(withMediaType: .video).first else {
            callback(nil)
            return
        }
        
        movie = GPUImageMovie(url: fileURL)
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        let renderSize = StoryConfg.videoSize
        writer = GPUImageMovieWriter(movieURL: url, size: renderSize)
        writer?.shouldPassthroughAudio = true
        let audioTracks = asset.tracks(withMediaType: .audio)
        if audioTracks.count > 0 {
            movie?.audioEncodingTarget = writer
        }
        movie?.enableSynchronizedEncoding(using: writer)
        
        let targetTransformFilter = GPUImageTransformFilter()
        transformFilter = targetTransformFilter
        var scaleX: CGFloat = 1
        var scaleY: CGFloat = 1
        var videoSize = track.naturalSize
        let orientation = self.orientation(videoTrack: track)
        if orientation == .portrait || orientation == .portraitUpsideDown {
            let size = videoSize
            videoSize.width = size.height
            videoSize.height = size.width
        }
        let videoRatio = abs(videoSize.width / videoSize.height)
        let renderRatio = renderSize.width / renderSize.height
        if videoRatio > renderRatio {
            scaleY = videoSize.height / renderSize.height * (renderSize.width / videoSize.width)
        } else if (videoRatio < renderRatio) {
            scaleX = videoSize.width / renderSize.width * (renderSize.height / videoSize.height)
        }
        targetTransformFilter.affineTransform = CGAffineTransform.identity.scaledBy(x: scaleX, y: scaleY)
        movie?.addTarget(targetTransformFilter)
        targetTransformFilter.addTarget(filter)
        
        let imageView = UIImageView(image: overlay)
        let uiElement = GPUImageUIElement(view: imageView)
        filter.frameProcessingCompletionBlock = { _, time in uiElement?.update(withTimestamp: time) }
        let targetBlendFilter = GPUImageAlphaBlendFilter()
        targetBlendFilter.mix = 1
        blendFilter = targetBlendFilter
        filter.addTarget(targetBlendFilter)
        uiElement?.addTarget(targetBlendFilter)
        targetBlendFilter.addTarget(writer)
        writer?.setInputRotation(imageRotationMode(forUIInterfaceOrientation: orientation), at: 0)
        writer?.startRecording()
        movie?.startProcessing()
        let clean: () -> Void = { [weak self] in
            targetBlendFilter.removeAllTargets()
            filter.removeAllTargets()
            uiElement?.removeAllTargets()
            self?.movie?.removeAllTargets()
            self?.blendFilter = nil
            self?.transformFilter = nil
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
    
    private func imageRotationMode(forUIInterfaceOrientation: UIInterfaceOrientation) -> GPUImageRotationMode {
        switch forUIInterfaceOrientation {
        case .landscapeRight:
            return GPUImageRotationMode.rotate180
        case .landscapeLeft:
            return GPUImageRotationMode.noRotation
        case .portrait:
            return GPUImageRotationMode.rotateRight
        case .portraitUpsideDown:
            return GPUImageRotationMode.rotateLeft
        default:
            return GPUImageRotationMode.noRotation
        }
    }
    
    private func orientation(videoTrack: AVAssetTrack) -> UIInterfaceOrientation {
        let trackTransform = videoTrack.preferredTransform
        if trackTransform.a == -1 && trackTransform.d == -1 {
            return UIInterfaceOrientation.landscapeRight
        } else if trackTransform.a == 1 && trackTransform.d == 1  {
            return UIInterfaceOrientation.landscapeLeft
        } else if trackTransform.b == -1 && trackTransform.c == 1 {
            return UIInterfaceOrientation.portraitUpsideDown
        } else {
            return UIInterfaceOrientation.portrait
        }
    }
}
