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
    var isStarted: Bool {
        return camera?.isRunning ?? false
    }
    private var filter = BeautyFilter()
    private var camera: GPUImageStillCamera?
    private var writer: GPUImageMovieWriter?
    private var queue = DispatchQueue.global()
    
    private var isCameraSetuping = false
    
    func setupCamera(callback: (() -> Void)? = nil) {
        guard camera == nil else {
            callback?()
            return
        }
        guard isCameraSetuping == false else { return }
        isCameraSetuping = true
        queue.async {
            self.fillMode = .preserveAspectRatioAndFill
            self.camera = GPUImageStillCamera(sessionPreset: StoryConfg.captureSessionPreset, cameraPosition: .back)
            self.camera?.outputImageOrientation = .portrait
            self.camera?.horizontallyMirrorFrontFacingCamera = true
            self.camera?.addTarget(self.filter)
            self.filter.addTarget(self)
            self.isCameraSetuping = false
            DispatchQueue.main.async { callback?() }
        }
    }
    
    func enableAudio(callback: (() -> Void)? = nil) {
        queue.async {
            self.camera?.addAudioInputsAndOutputs()
            DispatchQueue.main.async { callback?() }
        }
    }
    
    func rotateCamera(callback: (() -> Void)? = nil) {
        queue.async {
            self.camera?.rotateCamera()
            DispatchQueue.main.async { callback?() }
        }
    }
    
    func switchFlash(callback: (() -> Void)? = nil) {
        guard camera?.inputCamera.hasFlash == true && camera?.inputCamera.hasTorch == true else {
            callback?()
            return
        }
        guard var rawValue = camera?.inputCamera.torchMode.rawValue else {
            callback?()
            return
        }
        queue.async {
            rawValue += 1
            let mode = AVCaptureDevice.TorchMode(rawValue: rawValue + 1 > 3 ? 0 : rawValue)!
            do {
                try self.camera?.inputCamera.lockForConfiguration()
                self.camera?.inputCamera.torchMode = mode
                self.camera?.inputCamera.unlockForConfiguration()
            } catch {
                logger.error(error)
            }
            callback?()
        }
    }
    
    private var isStarting = false
    
    func startCaputre(callback: (() -> Void)? = nil) {
        guard isStarting == false, isStarted == false, camera != nil else { return }
        isStarting = true
        queue.async {
            self.camera?.startCapture()
            self.isStarting = false
            DispatchQueue.main.async { callback?() }
        }
    }
    
    private var isPausing = false
    
    func pauseCamera(callback: (() -> Void)? = nil) {
        guard isPausing == false, camera != nil else { return }
        isPausing = true
        queue.async {
            self.camera?.pauseCapture()
            self.isPaused = true
            self.isPausing = false
            DispatchQueue.main.async { callback?() }
        }
    }
    
    private var isResuming = false
    
    func resumeCamera(callback: (() -> Void)? = nil) {
        guard isResuming == false, camera != nil else { return }
        isResuming = true
        queue.async {
            self.camera?.resumeCameraCapture()
            self.isPaused = false
            self.isResuming = false
            DispatchQueue.main.async { callback?() }
        }
    }
    
    private var isStopping = false
    
    func stopCapture(callback: (() -> Void)? = nil) {
        guard isStopping == false, isStarted == true, camera != nil else { return }
        isStopping = true
        queue.async {
            self.camera?.stopCapture()
            self.isStopping = false
            DispatchQueue.main.async { callback?() }
        }
    }
    
    private var isStartingRecording = false
    
    func startRecording(callback: (() -> Void)? = nil) {
        guard isStartingRecording == false else { return }
        isStartingRecording = true
        queue.async {
            self.setupRecording()
            DispatchQueue.main.async {
                self.writer?.startRecording()
                self.isStartingRecording = false
                callback?()
            }
        }
    }
    
    private var isFinishingRecording = false
    
    func finishRecording(_ callback: @escaping ((URL?) -> Void)) {
        guard isFinishingRecording == false else { return }
        isFinishingRecording = true
        queue.async {
            self.writer?.finishRecording(completionHandler: { [weak self] in
                DispatchQueue.main.async {
                    guard let `self` = self else { return }
                    let url = self.writer?.assetWriter.outputURL
                    self.cleanRecording()
                    self.isFinishingRecording = false
                    callback(url)
                }
            })
        }
    }
    
    private var isPhotoCapturing = false
    
    func capturePhoto(_ callback: @escaping ((URL?) -> Void)) {
        guard isPhotoCapturing == false else { return }
        isPhotoCapturing = true
        queue.async {
            self.camera?.capturePhotoAsJPEGProcessedUp(
                toFilter: self.filter,
                withCompletionHandler: { [weak self] (data, error) in
                DispatchQueue.main.async {
                    guard let `self` = self else { return }
                    self.cleanRecording()
                    self.isPhotoCapturing = false
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
    }
    
    // MARK: - Private
    
    private func setupRecording() {
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        let writer = GPUImageMovieWriter(
            movieURL: url,
            size: StoryConfg.videoSize,
            fileType: AVFileType.mov.rawValue,
            outputSettings: StoryConfg.videoSetting
        )
        if writer == nil { logger.error("writer is nil") }
        self.writer = writer
        self.writer?.encodingLiveVideo = true
        self.writer?.shouldPassthroughAudio = true
        self.writer?.setHasAudioTrack(true, audioSettings: StoryConfg.audioSetting)
        self.camera?.audioEncodingTarget = writer
        self.filter.addTarget(writer)
    }
    
    private var isCleaning = false
    
    private func cleanRecording(callback: (() -> Void)? = nil) {
        guard isCleaning == false else { return }
        isCleaning = true
        queue.async {
            self.filter.removeTarget(self.writer)
            self.writer = nil
            self.camera?.audioEncodingTarget = nil
            GPUImageContext.sharedImageProcessing().framebufferCache.purgeAllUnassignedFramebuffers()
            GPUImageContext.sharedFramebufferCache().purgeAllUnassignedFramebuffers()
            self.isCleaning = false
            DispatchQueue.main.async { callback?() }
        }
    }
}

struct StoryConfg {
    static let captureSessionPreset: String = AVCaptureSession.Preset.high.rawValue
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
