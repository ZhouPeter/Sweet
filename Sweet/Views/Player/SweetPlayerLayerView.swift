//
//  BMPlayerLayerView.swift
//  Pods
//
//  Created by BrikerMan on 16/4/28.
//
//

import UIKit
import AVFoundation

/**
 Player status emun
 
 - notSetURL:      not set url yet
 - readyToPlay:    player ready to play
 - buffering:      player buffering
 - bufferFinished: buffer finished
 - playedToTheEnd: played to the End
 - error:          error with playing
 */
enum SweetPlayerState {
    case notSetURL
    case readyToPlay
    case buffering
    case bufferFinished
    case playedToTheEnd
    case error
}

/**
 video aspect ratio types
 
 - `default`:    video default aspect
 - sixteen2NINE: 16:9
 - four2THREE:   4:3
 */
enum SweetPlayerAspectRatio: Int {
    case `default`    = 0
    case sixteen2NINE
    case four2THREE
}

protocol SweetPlayerLayerViewDelegate: class {
    func sweetPlayer(player: SweetPlayerLayerView,
                     playerStateDidChange state: SweetPlayerState)
    func sweetPlayer(player: SweetPlayerLayerView,
                     loadedTimeDidChange loadedDuration: TimeInterval,
                     totalDuration: TimeInterval)
    func sweetPlayer(player: SweetPlayerLayerView,
                     playTimeDidChange currentTime: TimeInterval,
                     totalTime: TimeInterval)
    func sweetPlayer(player: SweetPlayerLayerView,
                     playerIsPlaying playing: Bool)
}

class SweetPlayerLayerView: UIView {
     weak var delegate: SweetPlayerLayerViewDelegate?
    /// 视频跳转秒数置0
    var seekTime = 0
    /// 播放属性
    var playerItem: AVPlayerItem? {
        didSet {
            onPlayerItemChange()
        }
    }
    /// 播放属性
    var player: AVPlayer? {
        willSet {
            self.playerLayer?.player = newValue
        }
    }

    var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    var isPlaying: Bool = false {
        didSet {
            if oldValue != isPlaying {
                delegate?.sweetPlayer(player: self, playerIsPlaying: isPlaying)
            }
        }
    }
    var isHasVolume: Bool = true
    
    var aspectRatio: SweetPlayerAspectRatio = .default {
        didSet {
            self.setNeedsLayout()
        }
    }
    
    /// 计时器
    var timer: Timer?
    
    fileprivate var urlAsset: AVURLAsset?
    
    fileprivate var lastPlayerItem: AVPlayerItem?
    
    /// playerLayer
    fileprivate var playerLayer: AVPlayerLayer?
    /// 音量滑杆
    fileprivate var volumeViewSlider: UISlider!
    /// 播放器的几种状态
    fileprivate var state = SweetPlayerState.notSetURL {
        didSet {
            if state != oldValue {
                delegate?.sweetPlayer(player: self, playerStateDidChange: state)
            }
        }
    }
    /// 是否为全屏
    fileprivate var isFullScreen  = false
    /// 是否锁定屏幕方向
    fileprivate var isLocked      = false
    /// 是否在调节音量
    fileprivate var isVolume      = false
    /// 是否播放声音
    /// 是否播放本地文件
    fileprivate var isLocalVideo  = false
    /// slider上次的值
    fileprivate var sliderLastValue: Float = 0
    /// 是否点了重播
    fileprivate var repeatToPlay  = false
    /// 播放完了
    fileprivate var playDidEnd    = false
    // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
    // 仅在bufferingSomeSecond里面使用
    fileprivate var isBuffering     = false
    fileprivate var hasReadyToPlay  = false
    fileprivate var shouldSeekTo: TimeInterval = 0
    
    // MARK: - Actions
    open func playURL(url: URL) {
        let asset = AVURLAsset(url: url)
        playAsset(asset: asset)
    }
    
    open func playAsset(asset: AVURLAsset) {
        urlAsset = asset
        onSetVideoAsset()
        play()
    }
    
    open func playAVPlayer(player: AVPlayer) {
        self.player = player
        onSetVideoAvPlayer()
        play()
    }
    
    open func play() {
        if let player = player {
            player.play()
            if !isHasVolume {
                player.volume = 0
            } else {
                player.volume = AVAudioSession.sharedInstance().outputVolume
            }
            setupTimer()
            isPlaying = true
        }
    }
    
    open func pause() {
        player?.pause()
        isPlaying = false
        timer?.fireDate = Date.distantFuture
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        statusToken?.invalidate()
        loadedToken?.invalidate()
        bufferEmptyToken?.invalidate()
        keepUpToken?.invalidate()
        rateToken?.invalidate()
    }

    // MARK: - layoutSubviews
    override open func layoutSubviews() {
        super.layoutSubviews()
        switch self.aspectRatio {
        case .default:
            self.playerLayer?.videoGravity = videoGravity
            self.playerLayer?.frame  = self.bounds
        case .sixteen2NINE:
            self.playerLayer?.videoGravity = videoGravity
            self.playerLayer?.frame = CGRect(x: 0, y: 0, width: self.bounds.width, height: self.bounds.width/(16/9))
        case .four2THREE:
            self.playerLayer?.videoGravity = videoGravity
            let width = self.bounds.height * 4 / 3
            self.playerLayer?.frame = CGRect(x: (self.bounds.width - width )/2,
                                             y: 0,
                                             width: width,
                                             height: self.bounds.height)
        }
    }
    
    func playerToNil() {
        self.player = nil
        self.timer?.invalidate()
    }
    
    open func resetPlayer() {
        // 初始化状态变量
        self.playDidEnd = false
        self.playerItem = nil
        self.seekTime   = 0
        self.timer?.invalidate()
//        self.pause()
        // 移除原来的layer
        self.playerLayer?.removeFromSuperlayer()
        // 替换PlayerItem为nil
//        self.player?.replaceCurrentItem(with: nil)
        self.rateToken?.invalidate()
        self.statusToken?.invalidate()
        self.loadedToken?.invalidate()
        self.bufferEmptyToken?.invalidate()
        self.keepUpToken?.invalidate()
        // 把player置为nil
        self.player = nil
    }
    
    open func prepareToDeinit() {
        self.resetPlayer()
    }
    
    open func onTimeSliderBegan() {
        if self.player?.currentItem?.status == .readyToPlay {
            self.timer?.fireDate = Date.distantFuture
        }
    }
    
    open func seek(to secounds: TimeInterval, completion:(() -> Void)?) {
        if secounds.isNaN {
            return
        }
        setupTimer()
        if self.player?.currentItem?.status == .readyToPlay {
            let draggedTime = CMTimeMake(Int64(secounds), 1)
            self.player!.seek(to: draggedTime,
                              toleranceBefore: kCMTimeZero,
                              toleranceAfter: kCMTimeZero,
                              completionHandler: { (_) in
                                completion?()
            })
        } else {
            self.shouldSeekTo = secounds
        }
    }
    
    fileprivate func onSetVideoAvPlayer() {
        repeatToPlay = false
        playDidEnd   = false
        configPlayerNoAsset()
    }
    // MARK: - 设置视频URL
    fileprivate func onSetVideoAsset() {
        repeatToPlay = false
        playDidEnd   = false
        configPlayer()
    }
    
    fileprivate func onPlayerItemChange() {
        if lastPlayerItem == playerItem {
            return
        }
        if let item = lastPlayerItem {
            NotificationCenter.default.removeObserver(
                self,
                name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                object: item)
            statusToken?.invalidate()
            loadedToken?.invalidate()
            bufferEmptyToken?.invalidate()
            keepUpToken?.invalidate()
        }
        
        lastPlayerItem = playerItem
        
        if let item = playerItem {
            NotificationCenter.default.addObserver(self, selector: #selector(moviePlayDidEnd),
                                                   name: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                   object: playerItem)
            
            statusToken = item.observe(\.status, options: .new) { (_, _) in
                if self.player?.status == .readyToPlay {
                    self.state = .buffering
                    if self.shouldSeekTo != 0 {
                        print("SweetPlayerLayer | Should seek to \(self.shouldSeekTo)")
                        self.seek(to: self.shouldSeekTo, completion: {
                            self.shouldSeekTo = 0
                            self.hasReadyToPlay = true
                            self.state = .readyToPlay
                        })
                    } else {
                        self.hasReadyToPlay = true
                        self.state = .readyToPlay
                    }
                } else if self.player?.status == .failed {
                    self.state = .error
                }
            }
            loadedToken = item.observe(\.loadedTimeRanges, options: .new, changeHandler: { (_, _) in
                // 计算缓冲进度
                if let timeInterVarl = self.availableDuration() {
                    let duration = item.duration
                    let totalDuration = CMTimeGetSeconds(duration)
                    self.delegate?.sweetPlayer(player: self,
                                               loadedTimeDidChange: timeInterVarl,
                                               totalDuration: totalDuration)
                }
            })
            // 缓冲区空了，需要等待数据
            bufferEmptyToken = item.observe(\.playbackBufferEmpty, options: .new, changeHandler: { (_, _) in
                // 当缓冲是空的时候
                if self.playerItem!.isPlaybackBufferEmpty {
                    self.state = .buffering
                    self.bufferingSomeSecond()
                }
            })
            // 缓冲区有足够数据可以播放了
            keepUpToken = item.observe(\.playbackLikelyToKeepUp, options: .new, changeHandler: { (_, _) in
                if item.isPlaybackBufferEmpty {
                    if self.state != .bufferFinished && self.hasReadyToPlay {
                        self.state = .bufferFinished
                        self.playDidEnd = true
                    }
                }
            })
          
        }
    }
    private var statusToken: NSKeyValueObservation?
    private var loadedToken: NSKeyValueObservation?
    private var bufferEmptyToken: NSKeyValueObservation?
    private var keepUpToken: NSKeyValueObservation?
    private var rateToken: NSKeyValueObservation?
    fileprivate func configPlayer() {
        rateToken?.invalidate()
        playerItem = AVPlayerItem(asset: urlAsset!)
        player     = AVPlayer(playerItem: playerItem!)
        rateToken = player?.observe(\.rate, options: .new, changeHandler: { (_, _) in
            self.updateStatus()
        })
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer!.videoGravity = videoGravity
        layer.addSublayer(playerLayer!)
        setNeedsLayout()
        layoutIfNeeded()
    }
    fileprivate func configPlayerNoAsset() {
        rateToken?.invalidate()
        playerItem = player?.currentItem
        rateToken = player?.observe(\.rate, options: .new, changeHandler: { (_, _) in
            self.updateStatus()
        })
        playerLayer?.removeFromSuperlayer()
        playerLayer = AVPlayerLayer(player: player)
        playerLayer?.videoGravity = videoGravity
        layer.addSublayer(playerLayer!)
        setNeedsLayout()
        layoutIfNeeded()
    }
    
    func setupTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: 0.5,
                                     target: self,
                                     selector: #selector(playerTimerAction),
                                     userInfo: nil,
                                     repeats: true)
        timer?.fireDate = Date()
    }
    
    // MARK: - 计时器事件
    @objc fileprivate func playerTimerAction() {
        if let playerItem = playerItem {
            if playerItem.duration.timescale != 0 {
                let currentTime = CMTimeGetSeconds(self.player!.currentTime())
                let totalTime   = TimeInterval(playerItem.duration.value) / TimeInterval(playerItem.duration.timescale)
                delegate?.sweetPlayer(player: self,
                                      playTimeDidChange: currentTime,
                                      totalTime: totalTime)
            }
            updateStatus(inclodeLoading: true)
        }
    }
    
    fileprivate func updateStatus(inclodeLoading: Bool = false) {
        if let player = player {
            if let playerItem = playerItem {
                if inclodeLoading {
                    if playerItem.isPlaybackLikelyToKeepUp || playerItem.isPlaybackBufferFull {
                        self.state = .bufferFinished
                    } else {
                        self.state = .buffering
                    }
                }
            }
            if player.rate == 0.0 {
                if player.error != nil {
                    self.state = .error
                    return
                }
                if let currentItem = player.currentItem {
                    if player.currentTime() >= currentItem.duration {
                        moviePlayDidEnd()
                        return
                    }
                    if currentItem.isPlaybackLikelyToKeepUp || currentItem.isPlaybackBufferFull {
                        
                    }
                }
            }
        }
    }
    
    // MARK: - Notification Event
    @objc fileprivate func moviePlayDidEnd() {
        if state != .playedToTheEnd {
            if let playerItem = playerItem {
                delegate?.sweetPlayer(player: self,
                                   playTimeDidChange: CMTimeGetSeconds(playerItem.duration),
                                   totalTime: CMTimeGetSeconds(playerItem.duration))
            }
            
            self.state = .playedToTheEnd
            self.isPlaying = false
            self.playDidEnd = true
            self.timer?.invalidate()
        }
    }
    
    /**
     缓冲进度
     
     - returns: 缓冲进度
     */
    fileprivate func availableDuration() -> TimeInterval? {
        if let loadedTimeRanges = player?.currentItem?.loadedTimeRanges,
            let first = loadedTimeRanges.first {
            let timeRange = first.timeRangeValue
            let startSeconds = CMTimeGetSeconds(timeRange.start)
            let durationSecound = CMTimeGetSeconds(timeRange.duration)
            let result = startSeconds + durationSecound
            return result
        }
        return nil
    }
    
    /**
     缓冲比较差的时候
     */
    fileprivate func bufferingSomeSecond() {
        self.state = .buffering
        // playbackBufferEmpty会反复进入，因此在bufferingOneSecond延时播放执行完之前再调用bufferingSomeSecond都忽略
        
        if isBuffering {
            return
        }
        isBuffering = true
        // 需要先暂停一小会之后再播放，否则网络状况不好的时候时间在走，声音播放不出来
        player?.pause()
        let popTime = DispatchTime.now() + Double(Int64( Double(NSEC_PER_SEC) * 1.0 )) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: popTime) {
            
            // 如果执行了play还是没有播放则说明还没有缓存好，则再次缓存一段时间
            self.isBuffering = false
            if let item = self.playerItem {
                if !item.isPlaybackLikelyToKeepUp {
                    self.bufferingSomeSecond()
                } else {
                    // 如果此时用户已经暂停了，则不再需要开启播放了
                    self.state = .bufferFinished
                }
            }
        }
    }
}