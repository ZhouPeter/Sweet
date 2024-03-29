//
//  SweetPlayerView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation

protocol SweetPlayerViewDelegate: class {
    func sweetPlayer(player: SweetPlayerView,
                     playerStateDidChange state: SweetPlayerState)
    func sweetPlayer(player: SweetPlayerView,
                     loadedTimeDidChange loadedDuration: TimeInterval,
                     totalDuration: TimeInterval)
    func sweetPlayer(player: SweetPlayerView,
                     playTimeDidChange currentTime: TimeInterval,
                     totalTime: TimeInterval)
    func sweetPlayer(player: SweetPlayerView,
                     playerIsPlaying playing: Bool)
    func sweetPlayer(player: SweetPlayerView,
                     playerOrientChanged isFullscreen: Bool)
    func sweetPlayer(player: SweetPlayerView,
                     isMuted: Bool)
    func sweetPlayerSwipeDown(pan: UIPanGestureRecognizer)
}

extension SweetPlayerViewDelegate {
    func sweetPlayer(player: SweetPlayerView,
                     playerStateDidChange state: SweetPlayerState) {}
    func sweetPlayer(player: SweetPlayerView,
                     loadedTimeDidChange loadedDuration: TimeInterval,
                     totalDuration: TimeInterval) {}
    func sweetPlayer(player: SweetPlayerView,
                     playTimeDidChange currentTime: TimeInterval,
                     totalTime: TimeInterval) {}
    func sweetPlayer(player: SweetPlayerView,
                     playerIsPlaying playing: Bool) {}
    func sweetPlayer(player: SweetPlayerView,
                     playerOrientChanged isFullscreen: Bool) {}
    func sweetPlayer(player: SweetPlayerView,
                     isMuted: Bool) {}
    func sweetPlayerSwipeDown(pan: UIPanGestureRecognizer) {}
}

enum PanDirection: Int {
    case horizontal = 0
    case vertical   = 1
}

class SweetPlayerView: UIView {
    weak var delegate: SweetPlayerViewDelegate?
    var backBlock: ((Bool) -> Void)?
    var panGesture: UIPanGestureRecognizer!
    fileprivate var isFullScreen: Bool {
        return UIApplication.shared.statusBarOrientation.isLandscape
    }
    var controlView: SweetPlayerControlView!
    lazy var placeholderImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    fileprivate var panDirection = PanDirection.horizontal
    fileprivate var sumTime: TimeInterval = 0
    fileprivate var totalDuration: TimeInterval = 0
    fileprivate var currentPosition: TimeInterval = 0
    fileprivate var shouldSeekTo: TimeInterval = 0
    
    fileprivate var isSliderSliding = false
    fileprivate var isPauseByUser   = false
    fileprivate var isMaskShowing   = false
    fileprivate var isSlowed        = false
    fileprivate var isVolume        = false
    fileprivate var isPlayToTheEnd  = false
    fileprivate var isURLSet        = false
    fileprivate var isRemove        = false
  
    var isVideoMuted = true {
        didSet {
            playerLayer?.isVideoMuted = isVideoMuted
            controlView.isVideoMuted = isVideoMuted
        }
    }
    weak var avPlayer: AVPlayer? {
        get {
            return playerLayer?.player
        }
        set {
            playerLayer?.player = newValue
        }
    }
    
    var savePlayer: AVPlayer?
    var playerLayer: SweetPlayerLayerView?
    var resource: SweetPlayerResource!
    
    var currentDefinition = 0
    var videoGravity = AVLayerVideoGravity.resizeAspect {
        didSet {
            self.playerLayer?.videoGravity = videoGravity
        }
    }
    
    init(controlView: SweetPlayerControlView = SweetPlayerControlView()) {
        super.init(frame: .zero)
        self.controlView = controlView
        self.initUI()
        self.initUIData()
        self.preparePlayer()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerLayer?.prepareToDeinit()
        removeUIData()
    }
    
    private func initUI() {
        addSubview(placeholderImageView)
        placeholderImageView.fill(in: self)
        addSubview(controlView)
        controlView.fill(in: self)
        controlView.updateUI(isFullScreen)
        controlView.delegate = self
        controlView.player = self
        panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panDirection(_:)))
        panGesture.delegate = self
        self.addGestureRecognizer(panGesture)
    }
    
    @objc open func onOrientationChanged() {
        updateUI(isFullScreen)
        delegate?.sweetPlayer(player: self, playerOrientChanged: isFullScreen)
    }
    
    func preparePlayer() {
        playerLayer = SweetPlayerLayerView()
        playerLayer!.videoGravity = videoGravity
        insertSubview(playerLayer!, at: 0)
        playerLayer!.delegate = self
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer?.frame = bounds
    }
    
    func setVideo(url: URL, name: String) {
        let resource = SweetPlayerResource(url: url, name: name)
        self.setVideo(resource: resource)
    }
    
    func setVideo(resource: SweetPlayerResource) {
        isURLSet = false
        isRemove = false
        self.resource = resource
        controlView.prepareUI(for: resource)
//        controlView.playStateDidChange(isPlaying: sweetPlayerConf.shouldAutoPlay)
        if sweetPlayerConf.shouldAutoPlay {
            isURLSet = true
            let asset = resource.definitions[currentDefinition].avURLAsset
            playerLayer?.playAsset(asset: asset)
        } 
    }
    
    func setAVPlayer(player: AVPlayer) {
        isURLSet = false
        isRemove = false
        self.savePlayer = player
        controlView.prepareUI(for: self.resource)
//        controlView.playStateDidChange(isPlaying: sweetPlayerConf.shouldAutoPlay)
        if sweetPlayerConf.shouldAutoPlay {
            isURLSet = true
            playerLayer?.playAVPlayer(player: player)
        } else {
//            savePlayer?.pause()
            pause()
        }
    }
    
    func cleanPlayer() {
        self.playerLayer?.cleanPlayer()
        self.avPlayer = nil
    }
    
    fileprivate func initUIData() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onOrientationChanged),
            name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationWillEnterForeground),
            name: .UIApplicationWillEnterForeground,
            object: nil)
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(applicationDidEnterBackground),
            name: .UIApplicationDidEnterBackground,
            object: nil)
    }
    
    fileprivate func removeUIData() {
        NotificationCenter.default.removeObserver(
            self,
            name: NSNotification.Name.UIApplicationDidChangeStatusBarOrientation,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: .UIApplicationWillEnterForeground,
            object: nil)
        NotificationCenter.default.removeObserver(
            self,
            name: .UIApplicationDidEnterBackground,
            object: nil)
    }
    
    @objc private func applicationWillEnterForeground() {
        if !isRemove {
            play()
        }
    }
    @objc private func applicationDidEnterBackground() {
        pause()
    }
}

extension SweetPlayerView: UIGestureRecognizerDelegate {
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        guard let velocityPoint = (gestureRecognizer as? UIPanGestureRecognizer)?.velocity(in: self) else { return true }
        if velocityPoint.y > 0 && isFullScreen == false {
            return false
        } else {
            return true
        }
        
    }
}
// MARK: - Actions
extension SweetPlayerView {
    
    @objc private func panDirection(_ pan: UIPanGestureRecognizer) {
        // 根据在view上Pan的位置，确定是调音量还是亮度
        let locationPoint = pan.location(in: self)
        // 我们要响应水平移动和垂直移动
        // 根据上次和本次移动的位置，算出一个速率的point
        let velocityPoint = pan.velocity(in: self)
        // 判断是垂直移动还是水平移动
        switch pan.state {
        case UIGestureRecognizerState.began:
            // 使用绝对值来判断移动的方向
            let pointX = fabs(velocityPoint.x)
            let pointY = fabs(velocityPoint.y)
            if pointX > pointY {
                if sweetPlayerConf.enablePlaytimeGestures {
                    self.panDirection = .horizontal
                    // 给sumTime初值
                    if let player = playerLayer?.player {
                        let time = player.currentTime()
                        self.sumTime = TimeInterval(time.value) / TimeInterval(time.timescale)
                    }
                }
            } else {
                panDirection = .vertical
                if locationPoint.x > self.bounds.size.width / 2 {
                    self.isVolume = true
                } else {
                    self.isVolume = false
                }
            }
        case UIGestureRecognizerState.changed:
            switch panDirection {
            case .horizontal:
                self.horizontalMoved(velocityPoint.x)
            case .vertical:
                self.verticalMoved(velocityPoint.y)
            }
        case UIGestureRecognizerState.ended:
            // 移动结束也需要判断垂直或者平移
            // 比如水平移动结束时，要快进到指定位置，如果这里没有判断，当我们调节音量完之后，会出现屏幕跳动的bug
            switch panDirection {
            case .horizontal:
                isSliderSliding = false
                if isPlayToTheEnd {
                    isPlayToTheEnd = false
                    seek(self.sumTime, completion: {
                        self.play()
                    })
                } else {
                    seek(self.sumTime, completion: {
                        self.autoPlay()
                    })
                }
                // 把sumTime滞空，不然会越加越多
                self.sumTime = 0.0
            case .vertical:
                self.isVolume = false
                if isFullScreen {
                    fullScreenButtonPressed()
                } else if velocityPoint.y > 0 {
                    delegate?.sweetPlayerSwipeDown(pan: pan)
                }
            }
        default:
            break
        }
    }
    
}

extension SweetPlayerView {
    private func verticalMoved(_ value: CGFloat) {
    }
    
    private func horizontalMoved(_ value: CGFloat) {
        if !sweetPlayerConf.enablePlaytimeGestures { return }
        isSliderSliding = true
        if let playerItem = playerLayer?.playerItem {
            // 每次滑动需要叠加时间，通过一定的比例，使滑动一直处于统一水平
            self.sumTime += TimeInterval(value) / 100.0 * (TimeInterval(self.totalDuration)/400)
            let totalTime = playerItem.duration
            // 防止出现NAN
            if totalTime.timescale == 0 { return }
            let totalDuration   = TimeInterval(totalTime.value) / TimeInterval(totalTime.timescale)
            if self.sumTime >= totalDuration { self.sumTime = totalDuration}
            if self.sumTime <= 0 { self.sumTime = 0 }
            controlView.showSeekToView(to: sumTime, total: totalDuration, isAdd: value > 0)
        }
    }
    private func fullScreenButtonPressed() {
        controlView.updateUI(!self.isFullScreen)
        if isFullScreen {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .portrait
        } else {
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
            UIApplication.shared.statusBarOrientation = .landscapeRight
        }
    }
    
}

extension SweetPlayerView {
    func updateUI(_ isFullScreen: Bool) {
        controlView.updateUI(isFullScreen)
    }
    
    func play() {
        if resource == nil {
            return
        }
        if !isURLSet {
            if let player = savePlayer {
                playerLayer?.playAVPlayer(player: player)
            } else {
                let asset = resource.definitions[currentDefinition]
                playerLayer?.playAsset(asset: asset.avURLAsset)
            }
            isURLSet = true
        }
        playerLayer?.play()
        isPauseByUser = false
        isRemove = false
    }

    func autoPlay() {
        if !isPauseByUser && isURLSet && !isPlayToTheEnd {
            play()
        }
    }
    
    func pause(allowAutoPlay allow: Bool = false) {
        playerLayer?.pause()
        isPauseByUser = !allow
    }
    
    func pauseWithRemove(isRemove: Bool) {
        pause()
        self.isRemove = isRemove
        
    }
    
    func seek(_ toSecond: TimeInterval, completion: (() -> Void)? = nil) {
        playerLayer?.seek(to: toSecond, completion: completion)
    }
}
extension SweetPlayerView: SweetPlayerLayerViewDelegate {
    func sweetPlayer(player: SweetPlayerLayerView, playerStateDidChange state: SweetPlayerState) {
        if state == .notFoundURL {
            placeholderImageView.isHidden = true
        }
        controlView.playerStateDidChange(state: state)
        delegate?.sweetPlayer(player: self, playerStateDidChange: state)
        if state == . playedToTheEnd {
            seek(0) {
                self.play()
            }
        }
    }
    func sweetPlayer(player: SweetPlayerLayerView,
                     loadedTimeDidChange loadedDuration: TimeInterval,
                     totalDuration: TimeInterval) {
        
    }
    
    func sweetPlayer(player: SweetPlayerLayerView,
                     playTimeDidChange currentTime: TimeInterval,
                     totalTime: TimeInterval) {
        delegate?.sweetPlayer(player: self, playTimeDidChange: currentTime, totalTime: totalTime)
        self.currentPosition = currentTime
        self.totalDuration = totalTime
        if isSliderSliding { return }
        controlView.playTimeDidChange(currentTime: currentTime, totalTime: totalTime)
        controlView.totalDuration = totalTime
        
    }
    
    func sweetPlayer(player: SweetPlayerLayerView, playerIsPlaying playing: Bool) {
        placeholderImageView.isHidden = playing
        controlView.playStateDidChange(isPlaying: playing)
        delegate?.sweetPlayer(player: self, playerIsPlaying: playing)
        
    }
}
// MARK: - SweetPlayerControlViewDelegate
extension SweetPlayerView: SweetPlayerControlViewDelegate {
    func controlView(controlView: SweetPlayerControlView, didPressButton button: UIButton) {
        if let action = SweetPlayerControlView.ButtonType(rawValue: button.tag) {
            switch action {
            case .play:
                if button.isSelected {
                    pause()
                } else {
                    if isPlayToTheEnd {
                        seek(0) {
                            self.play()
                        }
                        controlView.hidePlayToTheEndView()
                        isPlayToTheEnd = false
                    }
                    play()
                }
            case .fullscreen:
                fullScreenButtonPressed()
            case .back:
                fullScreenButtonPressed()
            case .replay:
                isPlayToTheEnd = false
                controlView.hidePlayToTheEndView()
                seek(0)
                play()
            case .retry:
                if let player = avPlayer {
                    setAVPlayer(player: player)
                }
            case .mute:
                isVideoMuted = !isVideoMuted
                delegate?.sweetPlayer(player: self, isMuted: isVideoMuted)
            default:
                logger.error("unhandled Actions")
            }
        }
    }
    
    func controlView(controlView: SweetPlayerControlView,
                     slider: UISlider,
                     onSliderEvent event: UIControlEvents) {
        switch event {
        case .touchDown:
            isSliderSliding = true
        case .touchUpInside:
            isSliderSliding = false
            let target = self.totalDuration * Double(slider.value)
            if isPlayToTheEnd {
                isPlayToTheEnd = false
                seek(target) {
                    self.play()
                }
                controlView.hidePlayToTheEndView()
            } else {
                seek(target) {
                    self.autoPlay()
                }
            }
        default:
            break
        }
        
    }
}
