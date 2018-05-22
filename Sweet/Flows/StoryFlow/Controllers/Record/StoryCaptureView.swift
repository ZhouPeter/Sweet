//
//  StoryCaptureView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import GPUImage

final class StoryCaptureView: GPUImageView {
    private(set) var isPaused = false
    private(set) var isStarted = false
    private var filter = GPUImageBeautifyFilter()
    private var camera: GPUImageStillCamera?
    private var writer: GPUImageMovieWriter?
    
    func setupCamera() {
        guard camera == nil else { return }
        camera = GPUImageStillCamera(sessionPreset: StoryConfg.captureSessionPreset, cameraPosition: .back)
        camera?.outputImageOrientation = .portrait
        camera?.horizontallyMirrorFrontFacingCamera = true
        camera?.addTarget(filter)
        filter.addTarget(self)
    }
    
    func enableAudio() {
        camera?.addAudioInputsAndOutputs()
    }
    
    func rotateCamera() {
        camera?.rotateCamera()
    }
    
    func switchFlash() {
        if camera?.inputCamera.hasFlash == false || camera?.inputCamera.hasTorch == false {
            return
        }
        
        guard var rawValue = camera?.inputCamera.torchMode.rawValue else {
            return
        }
        rawValue += 1
        let mode = AVCaptureDevice.TorchMode(rawValue: rawValue + 1 > 3 ? 0 : rawValue)!
        do {
            try camera?.inputCamera.lockForConfiguration()
            camera?.inputCamera.torchMode = mode
            camera?.inputCamera.unlockForConfiguration()
        } catch {
            logger.error(error)
        }
    }
    
    func startCaputre() {
        camera?.startCapture()
        isStarted = true
    }
    
    func pauseCamera() {
        camera?.pauseCapture()
        isPaused = true
    }
    
    func resumeCamera() {
        camera?.resumeCameraCapture()
        isPaused = false
    }
    
    func stopCapture() {
        camera?.stopCapture()
        isStarted = false
    }
    
    func startRecording() {
        setupRecording()
        DispatchQueue.main.async { self.writer?.startRecording() }
    }
    
    func finishRecording(_ callback: @escaping ((URL?) -> Void)) {
        writer?.finishRecording(completionHandler: { [weak self] in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                let url = self.writer?.assetWriter.outputURL
                self.cleanRecording()
                callback(url)
            }
        })
    }
    
    func capturePhoto(_ callback: @escaping ((URL?) -> Void)) {
        camera?.capturePhotoAsJPEGProcessedUp(toFilter: filter, withCompletionHandler: { [weak self] (data, error) in
            DispatchQueue.main.async {
                guard let `self` = self else { return }
                self.cleanRecording()
                if let data = data {
                    let url = URL.photoCacheURL(withName: UUID().uuidString + ".jpg")
                    do {
                        try data.write(to: url)
                        callback(url)
                    } catch {
                        logger.error(error)
                        callback(nil)
                    }
                    return
                }
                logger.error(error ?? "unkown error")
                callback(nil)
            }
        })
    }
    
    // MARK: - Private
    
    private func setupRecording() {
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        writer = GPUImageMovieWriter(
            movieURL: url,
            size: StoryConfg.videoSize,
            fileType: AVFileType.mov.rawValue,
            outputSettings: StoryConfg.videoSetting
        )
        writer?.encodingLiveVideo = true
        writer?.shouldPassthroughAudio = true
        writer?.setHasAudioTrack(true, audioSettings: StoryConfg.audioSetting)
        camera?.audioEncodingTarget = writer
        filter.addTarget(writer)
    }
    
    private func cleanRecording() {
        filter.removeTarget(writer)
        writer = nil
        camera?.audioEncodingTarget = nil
        GPUImageContext.sharedImageProcessing().framebufferCache.purgeAllUnassignedFramebuffers()
        GPUImageContext.sharedFramebufferCache().purgeAllUnassignedFramebuffers()
    }
}

struct StoryConfg {
    static let captureSessionPreset: String = AVCaptureSession.Preset.hd1280x720.rawValue
    static let videoSize = CGSize(width: 720, height: 1280)
    static let photoSize = CGSize(width: 720, height: 1280)
    static let audioSetting = [
        AVFormatIDKey: kAudioFormatMPEG4AAC,
        AVNumberOfChannelsKey: 2,
        AVSampleRateKey: 16000,
        AVEncoderBitRateKey: 32000
    ]
    static let videoSetting: [String: Any] = [
        AVVideoCodecKey: AVVideoCodecH264,
        AVVideoWidthKey: 720,
        AVVideoHeightKey: 1280,
        AVVideoCompressionPropertiesKey:
            [
                AVVideoProfileLevelKey: AVVideoProfileLevelH264Main31,
                AVVideoAllowFrameReorderingKey: false,
                AVVideoAverageBitRateKey: 720 * 1280 * 3
        ]
    ]
}
