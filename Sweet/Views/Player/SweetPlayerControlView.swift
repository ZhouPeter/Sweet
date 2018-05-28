//
//  SweetPlayerView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol SweetPlayerControlViewDelegate: class {

    func controlView(controlView: SweetPlayerControlView, didPressButton button: UIButton)
    func controlView(controlView: SweetPlayerControlView,
                     slider: UISlider,
                     onSliderEvent event: UIControlEvents)
}

class SweetPlayerControlView: UIView {
    weak var delegate: SweetPlayerControlViewDelegate?
    weak var player: SweetPlayerView?
    var resource: SweetPlayerResource?
    var selectedIndex = 0
    var isFullscreen  = false
    var isMaskShowing = true
    var tapGesture: UITapGestureRecognizer!
    var totalDuration: TimeInterval = 0
    var delayItem: DispatchWorkItem?
    var playerLastState: SweetPlayerState = .notSetURL
    private lazy var bottomMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    private lazy var topMaskView: UIView = {
        let view = UIView()
        view.isUserInteractionEnabled = true
        view.backgroundColor = UIColor.clear
        return view
    }()
    private lazy var middleMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.clear
        view.alpha = 0
        return view
    }()
    
    private lazy var mainMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0)
        return view
    }()
    
    private lazy var  startButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        button.setImage(#imageLiteral(resourceName: "Stop"), for: .selected)
        button.tag = SweetPlayerControlView.ButtonType.play.rawValue
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var timeSlider: UISlider = {
        let silder = UISlider()
        silder.setThumbImage(#imageLiteral(resourceName: "Point"), for: .normal)
        silder.addTarget(self,
                         action: #selector(progressSliderTouchBegan(_:)),
                         for: .touchDown)
        
        silder.addTarget(self,
                         action: #selector(progressSliderValueChanged(_:)),
                         for: .valueChanged)
        
        silder.addTarget(self,
                         action: #selector(progressSliderTouchEnded(_:)),
                         for: [.touchUpInside, .touchCancel, .touchUpOutside])
        return silder
    }()
    
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00/00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    private lazy var fullButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Full"), for: .normal)
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        button.tag = SweetPlayerControlView.ButtonType.fullscreen.rawValue
        return button
    }()
    
    private lazy var closeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Close"), for: .normal)
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        button.tag = SweetPlayerControlView.ButtonType.back.rawValue
        return button
    }()
    
    private lazy var replayButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Replay"), for: .normal)
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        button.tag = SweetPlayerControlView.ButtonType.replay.rawValue
        return button
    }()
    
    private lazy var nextLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "03s后播放：妇联3的80个彩蛋…"
        return label
    }()
    
    private lazy var videoTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .white
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(mainMaskView)
        mainMaskView.fill(in: self)
//        mainMaskView.addSubview(middleMaskView)
//        middleMaskView.center(to: mainMaskView)
//        middleMaskView.equal(.width, to: mainMaskView)
//        middleMaskView.equal(.height, to: mainMaskView, offset: 110)
//        middleMaskView.addSubview(replayButton)
//        replayButton.constrain(width: 30, height: 30)
//        replayButton.center(to: middleMaskView)
//        middleMaskView.addSubview(nextLabel)
//        nextLabel.centerX(to: middleMaskView)
//        nextLabel.pin(.bottom, to: replayButton, spacing: 10)
        
        mainMaskView.addSubview(bottomMaskView)
        bottomMaskView.align(.left, to: mainMaskView)
        bottomMaskView.align(.right, to: mainMaskView)
        bottomMaskView.align(.bottom, to: mainMaskView)
        bottomMaskView.constrain(height: 50)
        
        bottomMaskView.addSubview(startButton)
        startButton.constrain(width: 50, height: 50)
        startButton.align(.left, to: bottomMaskView)
        startButton.centerY(to: bottomMaskView)
        
        bottomMaskView.addSubview(timeSlider)
        timeSlider.centerY(to: bottomMaskView)
        timeSlider.pin(.right, to: startButton)
        timeSlider.constrain(height: 50)
        
        bottomMaskView.addSubview(timeLabel)
        timeLabel.centerY(to: bottomMaskView)
        timeLabel.constrain(width: 85, height: 20)
        timeLabel.pin(.right, to: timeSlider, spacing: 5)
        
        bottomMaskView.addSubview(fullButton)
        fullButton.constrain(width: 50, height: 50)
        fullButton.align(.right, to: bottomMaskView)
        fullButton.centerY(to: bottomMaskView)
        fullButton.pin(.right, to: timeLabel).priority = .defaultHigh
        bottomMaskView.addSubview(videoTitleLabel)
        videoTitleLabel.pin(.bottom, to: bottomMaskView)
        videoTitleLabel.align(.left, to: bottomMaskView, inset: 10)
        videoTitleLabel.constrain(height: 25)
        
        mainMaskView.addSubview(topMaskView)
        topMaskView.align(.left, to: mainMaskView)
        topMaskView.align(.right, to: mainMaskView)
        topMaskView.align(.top, to: mainMaskView)
        topMaskView.constrain(height: 60)
        topMaskView.addSubview(closeButton)
        closeButton.align(.left, to: topMaskView, inset: UIScreen.isIphoneX() ? 34 : 10)
        closeButton.align(.top, to: topMaskView, inset: 15)
        closeButton.constrain(width: 30, height: 30)
        
        tapGesture = UITapGestureRecognizer(target: self,
                                            action: #selector(onTapGestureTapped(_:)))
        addGestureRecognizer(tapGesture)
    }
    
    func playerStateDidChange(state: SweetPlayerState) {
        switch state {
        case .readyToPlay:
            break
        case .buffering:
            break
        case .bufferFinished:
            break
        case .playedToTheEnd:
            break
//            startButton.isSelected = false
//            showPlayToTheEndView()
//            controlViewAnimation(isShow: true)
        default:
            break
        }
        playerLastState = state
    }
    
    func playStateDidChange(isPlaying: Bool) {
        autoFadeOutControlViewWithAnimation()
        startButton.isSelected = isPlaying
    }
    
    func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        let currentText = SweetPlayerView.formatSecondsToString(currentTime)
        let totalText = SweetPlayerView.formatSecondsToString(totalTime)
        timeLabel.text = "\(currentText)/\(totalText)"
        timeSlider.value = Float(currentTime) / Float(totalTime)
    }
    
    func showSeekToView(to toSecound: TimeInterval, total totalDuration: TimeInterval, isAdd: Bool) {
        let targetText = SweetPlayerView.formatSecondsToString(toSecound)
        let totalText = SweetPlayerView.formatSecondsToString(totalDuration)
        timeLabel.text = "\(targetText)/\(totalText)"
        timeSlider.value = Float(toSecound) / Float(totalDuration)
        
    }
    func showPlayToTheEndView() {
//        middleMaskView.alpha = 1
        mainMaskView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
    }
    
    func hidePlayToTheEndView() {
//        middleMaskView.alpha = 0
        mainMaskView.backgroundColor = UIColor.black.withAlphaComponent(0)
    }
    
    func updateUI(_ isForFullScreen: Bool) {
        isFullscreen = isForFullScreen
        if isFullscreen {
            topMaskView.isHidden = false
        } else {
            topMaskView.isHidden = true
        }
    }
    
    func prepareUI(for resource: SweetPlayerResource, selectedIndex index: Int = 0) {
        self.resource = resource
        self.selectedIndex = index
        videoTitleLabel.text = resource.name
        autoFadeOutControlViewWithAnimation()
    }
    
}
// MARK: - Privates
extension SweetPlayerControlView {
    private func autoFadeOutControlViewWithAnimation() {
        cancelAutoFadeOutAnimation()
        delayItem = DispatchWorkItem { [weak self] in
            if self?.playerLastState != .playedToTheEnd {
                self?.controlViewAnimation(isShow: false)
            }
        }
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + sweetPlayerConf.animateDelayTimeInterval,
            execute: delayItem!)
    }
    private func cancelAutoFadeOutAnimation() {
        delayItem?.cancel()
    }
    
    private func controlViewAnimation(isShow: Bool) {
        let alpha: CGFloat = isShow ? 1.0 : 0.0
        isMaskShowing = isShow
        UIView .animate(withDuration: 0.3, animations: {
            self.bottomMaskView.alpha = alpha
            self.topMaskView.alpha = alpha
            self.layoutIfNeeded()
        }, completion: { (_) in
            if isShow { self.autoFadeOutControlViewWithAnimation() }
        })
    }
}

// MARK: - handle UI slider actions

extension SweetPlayerControlView {
    @objc private func onTapGestureTapped(_ gesture: UITapGestureRecognizer) {
        if playerLastState == .playedToTheEnd {
            return
        }
        controlViewAnimation(isShow: !isMaskShowing)
    }
    
    @objc private func onButtonPressed(_ button: UIButton) {
        autoFadeOutControlViewWithAnimation()
        if let type = ButtonType(rawValue: button.tag) {
            switch type {
            case .play:
                if playerLastState == .playedToTheEnd {
                    hidePlayToTheEndView()
                }
            default:
                break
            }
        }
        delegate?.controlView(controlView: self, didPressButton: button)
    }
    @objc func progressSliderTouchBegan(_ sender: UISlider) {
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchDown)
    }
    
    @objc func progressSliderValueChanged(_ sender: UISlider) {
        hidePlayToTheEndView()
        cancelAutoFadeOutAnimation()
        let currentTime = Double(sender.value) * totalDuration
        let currentText = SweetPlayerView.formatSecondsToString(currentTime)
        let totalText = SweetPlayerView.formatSecondsToString(totalDuration)
        timeLabel.text = "\(currentText)/\(totalText)"
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .valueChanged)
    }
    
    @objc func progressSliderTouchEnded(_ sender: UISlider) {
        autoFadeOutControlViewWithAnimation()
        delegate?.controlView(controlView: self, slider: sender, onSliderEvent: .touchUpInside)
    }
}