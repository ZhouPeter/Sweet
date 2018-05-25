//
//  VedioPlayerView.swift
//  MMFinancialSchool
//
//  Created by Alfred on 2017/8/2.
//  Copyright © 2017年 linweibiao. All rights reserved.
//

import UIKit
import AVFoundation

enum PlayWay {
    case online, local
}

public func formatPlayTime(_ secounds: TimeInterval) -> String {
    if secounds.isNaN {
        return "00:00"
    }
    let min = Int(secounds / 60)
    let sec = Int(secounds.truncatingRemainder(dividingBy: 60))
    return String(format: "%02d:%02d", min, sec)
}

class VideoPlayerView: UIView {
    static let shard = VideoPlayerView()
    var playSeekTimeDic: NSMutableDictionary!
    var videoIdLog: String! = ""//日志里记录的video_id
    var url: String! = "" {
        didSet {
            choose = PlayWay.online
            videoPlay()
        }
    }

    var filePath = "" {
        didSet {
            choose = PlayWay.local
            videoPlay()
        }
    }
    var choose = PlayWay.online
    var fatherView: UIView! {
        didSet {
            fatherView.addSubview(self)
            self.frame = fatherView.bounds
            coverImageView.frame = fatherView.bounds
        }
    }
    override func awakeFromNib() {
        let dic = UserDefaults.standard.object(forKey: "playSeekTimeDic") as? [AnyHashable: Any]
        let mutableDic: NSMutableDictionary = [:]
        mutableDic.setDictionary(dic ?? [:])
        playSeekTimeDic = mutableDic
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appWillResignActive),
                                               name: .UIApplicationWillResignActive,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(appDidBecomeActive),
                                               name: .UIApplicationDidBecomeActive,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(deviceDidRotate(notification:)),
                                               name: .UIDeviceOrientationDidChange,
                                               object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(videoPlayEnd),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        
        try? AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)//静音模式下播放声音
    }
    var holdImage: UIImage! {
        get {
            return netWaitingImageView.image
        }
        set {
            netWaitingImageView.image = newValue
            if fatherView != nil {
                fatherView.addSubview(netWaitingImageView)
                netWaitingImageView.frame = fatherView.bounds
            }
        }
    }
    @IBOutlet weak var coverImageView: UIImageView! {
        didSet {
            coverImageView.contentMode = .scaleToFill
            coverImageView.frame = CGRect(x: 0,
                                          y: 0,
                                          width: UIScreen.mainWidth(),
                                          height: UIScreen.mainWidth() * 400 / 750)
        }
    }
    @IBOutlet weak var netWaitingImageView: UIImageView!
    @IBOutlet weak var controlVView: ControlVView! {
        didSet {
            controlVView.alpha = CGFloat(0)
        }
    }
    
    @IBOutlet weak var controlHView: ControlHView! {
        didSet {
            controlHView.isHidden = true
            controlHView.alpha = CGFloat(0)
        }
    }
    var playerLayer: AVPlayerLayer!
    var playerPub: AVPlayer! {
        didSet {
            playerLayer = AVPlayerLayer(player: self.playerPub)
            playerLayer.frame = self.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            self.layer.addSublayer(playerLayer)
            self.addSubview(controlVView)
            self.addSubview(controlHView)
        }
    }
    
    var updateSiderValue = true
    @IBAction func sliderTouchDown(_ sender: UISlider) {
        updateSiderValue = false
    }
    
    @IBAction func sliderTouchOut(_ sender: UISlider) {
        //当视频状态为AVPlayerStatusReadyToPlay时才处理
        if playerPub.status == AVPlayerStatus.readyToPlay {
            let duration = sender.value * Float(CMTimeGetSeconds(playerPub.currentItem!.duration))
            let seekTime = CMTimeMake(Int64(duration), 1)
            playerPub.seek(to: seekTime, completionHandler: { (_) in
                self.updateSiderValue = true
            })
        }
    }
    
    @IBAction func fullScreenButtonClicked(_ sender: UIButton) {
        if UIDevice.current.orientation == UIDeviceOrientation.portrait {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            sender.isSelected = true
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            sender.isSelected = false
        }
    }
    
    func videoPlay() {
        playerPub?.pause()
        playerPub?.removeObserver(self, forKeyPath: "status")
        playerPub?.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        switch choose {
        case .local:
            playerPub = AVPlayer(url: URL(fileURLWithPath: filePath))
        case .online:
            playerPub = AVPlayer(url: URL(string: url)!)
        }
        let seconds = playSeekTimeDic.value(forKey: videoIdLog) as? Float ?? 0.0
        let cmTime = CMTime.init(seconds: Double(seconds), preferredTimescale: 1)
        playerPub.rate = 1 //加在KVO时候才生效
        playerPub.pause()
        playerPub.seek(to: cmTime)
        //获取字幕
        let item = playerPub.currentItem
        let asset = item?.asset
        let group = asset?.mediaSelectionGroup(forMediaCharacteristic: AVMediaCharacteristic.legible)
        if group != nil {
            let locale = Locale.init(identifier: "zh_CN")///en_US
            let options = AVMediaSelectionGroup.mediaSelectionOptions(from: (group?.options)!, with: locale)
            item?.select(options.first, in: group!)
        }
        //监听状态改变
        playerPub.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听缓冲进度改变
        playerPub.currentItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        playObserver = playerPub.addPeriodicTimeObserver(
            forInterval: CMTime(value: 1, timescale: 2),
            queue: DispatchQueue.main) { [weak self] (_) in
            guard let `self` = self else { return }
            let currentTime = self.playerPub.currentTime()
            let totalTime = self.playerPub.currentItem?.duration
            let progress = CMTimeGetSeconds(currentTime) / CMTimeGetSeconds(totalTime!)
            let text = formatPlayTime(CMTimeGetSeconds(currentTime)) + formatPlayTime(CMTimeGetSeconds(totalTime!))
            logger.debug(Float(progress))
            DispatchQueue.main.async {
                let boollet = self.updateSiderValue
                if boollet {
                    if self.updateSiderValue {
                        if !self.isDragged {
                            self.controlVView.videoPlaySlider.value = Float(progress)
                            self.controlHView.videoPlaySlider.value = Float(progress)
                            self.controlVView.timelabel.text = text
                            self.controlHView.timelabel.text = text
                        }
                    }
                }
            }
        }
    }
    // MARK: - notification#Selector
    var backPlayModel = true
    @objc func appWillResignActive() {
        logger.debug("appWillResignActive")
        if backPlayModel {
            playerLayer.player = nil
        } else {
            playerPub.pause()
        }
    }
    @objc func appDidBecomeActive() {
        logger.debug("appDidBecomeActive")
        if backPlayModel {
            playerLayer.player = playerPub
        }
    }
    
    @objc func deviceDidRotate(notification: NSNotification) {
        if UIDevice.current.orientation.rawValue == 5 || UIDevice.current.orientation.rawValue == 6 {
            return
        }
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
            videoViewHStatus()
        } else {
            videoViewVStatus()
        }
    }
    
    let horizontalFrame = CGRect(x: 0,
                                 y: 0,
                                 width: UIScreen.mainHeight(),
                                 height: UIScreen.mainWidth())
    let verticalFrame = CGRect(x: 0,
                               y: 0,
                               width: UIScreen.mainWidth(),
                               height: UIScreen.mainWidth() * 40 / 75)
    
    func videoViewVStatus() {
        controlVView.fullScreenButton.isSelected = false
        self.removeFromSuperview()
        self.frame = verticalFrame
        if playerLayer != nil {
            playerLayer.frame = self.bounds
            controlVView.frame = playerLayer.frame
        }
        if fatherView != nil {
            fatherView.addSubview(self)
        }
        controlVView.isHidden = false
        controlHView.isHidden = true
    }
    
    func videoViewHStatus() {
        controlVView.fullScreenButton.isSelected = true
        self.removeFromSuperview()
        self.frame = horizontalFrame
        playerLayer.frame = self.bounds
        if allowRotation == true {
            UIApplication.shared.keyWindow?.addSubview(self)
        }
        controlHView.frame = playerLayer.frame
        controlVView.isHidden = true
        controlHView.isHidden = false
    }
    
    var indexPath = 0
    var playEndBlock: ((Int) -> Void)!
    @objc func videoPlayEnd() {
        logger.debug("videoPlayEnd")
        if playEndBlock != nil {
            if UIDeviceOrientationIsLandscape(UIDevice.current.orientation) {
                UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue,
                                          forKey: "orientation")
            }
            playEndBlock(indexPath + 1)//下一个视频
        }
    }

    // MARK: - UIPanGestureRecognizer
    var lastVolume: Float = 0
    var lastBrightness: Float = Float(UIScreen.main.brightness)
    var panDirection: PanDirection = .horizontal
    var isVolume = true
    
    @IBAction func controlViewPanned(_ sender: UIPanGestureRecognizer) {
        if UIDeviceOrientationIsPortrait(UIDevice.current.orientation) {
            
        } else {//横
            let location = sender.location(in: controlHView)
            let velocty = sender.velocity(in: controlHView)
            switch sender.state {
            case .began:
                let veloctyX = fabs(velocty.x)
                let veloctyY = fabs(velocty.y)
                if veloctyX > veloctyY { //水平移动
                    logger.debug("水平移动began")
                    logger.debug("")
                    panDirection = .horizontal
                    sumValue = CGFloat(controlHView.videoPlaySlider.value)
                } else if veloctyX < veloctyY {//垂直移动
                    logger.debug("垂直移动began")
                    panDirection = .vertical
                    if location.x > UIScreen.mainHeight() / 2 {
                        logger.debug("音量")
                        isVolume = true
                    } else {
                        logger.debug("亮度")
                        isVolume = false
                    }
                }
            case .changed:
                switch panDirection {
                case .horizontal:
                    logger.debug("水平移动changed")
                    horizontalMoved(value: velocty.x)
                case .vertical:
                    logger.debug("垂直移动changed")
                    verticalMoved(value: velocty.y)
                }
            case .ended:
                switch panDirection {
                case .horizontal:
                    logger.debug("水平移动ended")
                    let sliderTime = CGFloat(controlHView.videoPlaySlider.value) *
                                CGFloat(CMTimeGetSeconds(playerPub.currentItem!.duration))
                    logger.debug(sliderTime)
                    let seekTime = CMTimeMake(Int64(sliderTime), 1)
                    playerPub.seek(to: seekTime)
                    isDragged = false
                    sumValue = 0
                case .vertical:
                    logger.debug("垂直移动ended")
                }
            default:
                break
            }
        }
    }
    var isDragged = false
    var sumValue: CGFloat = 0.0
    func horizontalMoved(value: CGFloat) {
        sumValue += value/50000
        controlHView.videoPlaySlider.value = Float(sumValue)
        isDragged = true
    }
    func verticalMoved(value: CGFloat) {
        if isVolume {//声音
            let volumeDelta = value / 10000
            let newVolume = lastVolume - Float(volumeDelta)
            SystemVolume.instance.setLastVolume(value: newVolume)
            lastVolume = newVolume
        } else {//亮度
            let volumeDelta = value / 10000
            let newVolume = lastBrightness - Float(volumeDelta)
            UIScreen.main.brightness = CGFloat(newVolume)
            lastBrightness = newVolume
        }
    }
    func avalableDurationWithplayerItem() -> TimeInterval {
        if let first = playerPub?.currentItem?.loadedTimeRanges.first {
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            return result
        } else {
            return 0
        }
        
    }
    override func observeValue (
        forKeyPath keyPath: String?,
        of object: Any?,
        change: [NSKeyValueChangeKey: Any]?,
        context: UnsafeMutableRawPointer?) {
        if keyPath == "loadedTimeRanges"{
            let loadedTime = avalableDurationWithplayerItem()
            let totalTime = CMTimeGetSeconds((playerPub.currentItem?.duration)!)
            let percent = loadedTime/totalTime
            controlVView.progressView.progress = Float(percent)
            controlHView.progressView.progress = Float(percent)
        } else if keyPath == "status" {
            if let player = object as? AVPlayer {
                if player.status == .readyToPlay {
                    if #available(iOS 10.0, *) {
                        Timer.scheduledTimer(withTimeInterval: 0.8, repeats: false, block: { (_) in
                            UIView.animate(withDuration: 1) {
                                [weak self] in
                                if self?.netWaitingImageView != nil {
                                    self?.netWaitingImageView.alpha = 0
                                }
                            }
                        })
                    } else {
                        // Fallback on earlier versions
                    }
                    if #available(iOS 10.0, *) {
                        Timer.scheduledTimer(withTimeInterval: 1.9, repeats: false, block: { [weak self] (_) in
                            self?.netWaitingImageView.isHidden = true
                            self?.netWaitingImageView.alpha = 1
                        })
                    } else {

                    }
                }
            }
        }
    }
    var playObserver: Any!
    func actionPlayExitLog() {
        if playerPub != nil {
            if playerPub.status == AVPlayerStatus.readyToPlay {
                let currentTime = controlVView.videoPlaySlider.value *
                    Float(CMTimeGetSeconds(playerPub.currentItem!.duration))
                playSeekTimeDic.setValue(currentTime, forKey: videoIdLog)
            }
        }
    }
    deinit {
        actionPlayExitLog()
        if playerPub != nil {
            playerPub.removeTimeObserver(playObserver)
            playerPub.removeObserver(self, forKeyPath: "status")
            playerPub.currentItem?.removeObserver(self, forKeyPath: "loadedTimeRanges")
        }
        UserDefaults.standard.set(playSeekTimeDic, forKey: "playSeekTimeDic")
    }
}

