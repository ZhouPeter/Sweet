//
//  VideoTrimmerViewController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/24.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
import MobileCoreServices
import PKHUD

extension AVPlayer {
    var isPlaying: Bool {
        return self.rate != 0 && self.error == nil
    }
}

class VideoTrimmerViewController: UIViewController {
    var onFinished: ((URL) -> Void)?
    private let playButton = UIButton()
    private let playerView = UIView()
    private let trimmerView = TrimmerView()
    private let fileURL: URL
    private var player: AVPlayer?
    private var playbackTimeCheckerTimer: Timer?
    private var trimmerPositionChangedTimer: Timer?
    private var session: AVAssetExportSession?
    private lazy var rightBarButtonItem =
        UIBarButtonItem(title: "继续", style: .plain, target: self, action: #selector(didPressRightBarButtonItem))
    private let durationLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .left
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    } ()
    
    init(fileURL: URL) {
        self.fileURL = fileURL
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        title = "裁剪视频"
        rightBarButtonItem.isEnabled = false
        navigationItem.rightBarButtonItem = rightBarButtonItem
        trimmerView.backgroundColor = UIColor(hex: 0x252525)
        trimmerView.handleColor = UIColor(hex: 0xa0a0a0)
        trimmerView.positionBarColor = UIColor(hex: 0x36C6FD)
        trimmerView.mainColor = .white
        playerView.backgroundColor = .black
        view.addSubview(playerView)
        playerView.align(.left)
        playerView.align(.right)
        playerView.centerY(to: view)
        playerView.constrain(height: 200)
        view.addSubview(trimmerView)
        trimmerView.constrain(height: 60)
        trimmerView.align(.left)
        trimmerView.align(.right)
        trimmerView.align(.bottom, to: view, inset: 60)
        view.addSubview(durationLabel)
        durationLabel.pin(.top, to: trimmerView, spacing: 10)
        durationLabel.align(.left, to: view, inset: 5)
        durationLabel.constrain(width: 150)
        let tipsLabel = UILabel()
        tipsLabel.textAlignment = .right
        tipsLabel.font = UIFont.systemFont(ofSize: 13)
        tipsLabel.textColor = UIColor(hex: 0x727272)
        tipsLabel.text = "上传视频时长需小于 10 秒"
        view.addSubview(tipsLabel)
        tipsLabel.align(.bottom, to: durationLabel)
        tipsLabel.align(.right, to: view, inset: 5)
        tipsLabel.constrain(width: 160)
        
        DispatchQueue.main.async { self.loadAsset(AVAsset(url: self.fileURL)) }
    }
    
    @objc private func didPressRightBarButtonItem() {
        session = AVAssetExportSession(asset: AVAsset(url: self.fileURL), presetName: AVAssetExportPreset1280x720)
        let url = URL.videoCacheURL(withName: UUID().uuidString + ".mp4")
        session?.outputURL = url
        session?.timeRange = CMTimeRangeMake(trimmerView.startTime!, trimmerView.endTime!)
        session?.outputFileType = .mp4
        PKHUD.sharedHUD.contentView = PKHUDSystemActivityIndicatorView()
        PKHUD.sharedHUD.show()
        self.player?.pause()
        self.stopPlaybackTimeChecker()
        session?.exportAsynchronously(completionHandler: { [weak self] in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                if self.session?.status == .completed {
                    PKHUD.sharedHUD.hide(true)
                    logger.debug(url)
                    self.onFinished?(url)
                } else {
                    PKHUD.toast(message: "导出失败")
                }
            }
        })
    }
    
    private func checkDuration() {
        let duration = (trimmerView.endTime! - trimmerView.startTime!).seconds
        logger.debug(duration)
        durationLabel.text = String(format: "已选取 %.1f 秒", duration)
        if duration >= 1 && duration <= 10 {
            rightBarButtonItem.isEnabled = true
        } else {
            rightBarButtonItem.isEnabled = false
        }
    }
    
    @objc private func play(_ sender: Any) {
        guard let player = player else { return }
        if !player.isPlaying {
            player.play()
            startPlaybackTimeChecker()
        } else {
            player.pause()
            stopPlaybackTimeChecker()
        }
    }
    
    private func loadAsset(_ asset: AVAsset) {
        trimmerView.asset = asset
        trimmerView.delegate = self
        addVideoPlayer(with: asset, playerView: playerView)
    }
    
    private func addVideoPlayer(with asset: AVAsset, playerView: UIView) {
        let playerItem = AVPlayerItem(asset: asset)
        player = AVPlayer(playerItem: playerItem)
        
        NotificationCenter.default.addObserver(self, selector: #selector(VideoTrimmerViewController.itemDidFinishPlaying(_:)),
                                               name: NSNotification.Name.AVPlayerItemDidPlayToEndTime, object: playerItem)
        
        let layer: AVPlayerLayer = AVPlayerLayer(player: player)
        layer.backgroundColor = UIColor.white.cgColor
        layer.frame = CGRect(x: 0, y: 0, width: playerView.frame.width, height: playerView.frame.height)
        layer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        playerView.layer.sublayers?.forEach({$0.removeFromSuperlayer()})
        playerView.layer.addSublayer(layer)
    }
    
    @objc func itemDidFinishPlaying(_ notification: Notification) {
        if let startTime = trimmerView.startTime {
            player?.seek(to: startTime)
        }
    }
    
    func startPlaybackTimeChecker() {
        stopPlaybackTimeChecker()
        playbackTimeCheckerTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                        selector:
            #selector(VideoTrimmerViewController.onPlaybackTimeChecker), userInfo: nil, repeats: true)
    }
    
    func stopPlaybackTimeChecker() {
        playbackTimeCheckerTimer?.invalidate()
        playbackTimeCheckerTimer = nil
    }
    
    @objc func onPlaybackTimeChecker() {
        guard let startTime = trimmerView.startTime, let endTime = trimmerView.endTime, let player = player else {
            return
        }
        
        let playBackTime = player.currentTime()
        trimmerView.seek(to: playBackTime)
        
        if playBackTime >= endTime {
            player.seek(to: startTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
            trimmerView.seek(to: startTime)
        }
    }
}

extension VideoTrimmerViewController: TrimmerViewDelegate {
    func positionBarStoppedMoving(_ playerTime: CMTime) {
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        player?.play()
        startPlaybackTimeChecker()
    }
    
    func didChangePositionBar(_ playerTime: CMTime) {
        stopPlaybackTimeChecker()
        player?.pause()
        player?.seek(to: playerTime, toleranceBefore: kCMTimeZero, toleranceAfter: kCMTimeZero)
        checkDuration()
    }
}
