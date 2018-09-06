//
//  SweetPlayerCellControlView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SweetPlayerCellControlView: SweetPlayerControlView {

    override var isVideoMuted: Bool {
        didSet {
            if isVideoMuted {
                voiceButton.setImage(#imageLiteral(resourceName: "Mute"), for: .normal)
            } else {
                voiceButton.setImage(#imageLiteral(resourceName: "Voice"), for: .normal)
            }
        }
    }
    
    private var playerButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Play"), for: .normal)
        button.tag = SweetPlayerControlView.ButtonType.play.rawValue
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        button.isHidden = true
        return button
    }()
    
    private lazy var noPlayMask: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.isUserInteractionEnabled = false
        view.isHidden = true
        return view
    }()
    
    private lazy var voiceButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Mute"), for: .normal)
        button.tag = SweetPlayerControlView.ButtonType.mute.rawValue
        button.addTarget(self, action: #selector(onButtonPressed(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var progressView: UIProgressView = {
        let view = UIProgressView()
        view.progressTintColor = UIColor.white
        return view
    }()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    override func customizeUIComponents() {
        bottomMaskView.isHidden = true
        topMaskView.isHidden = true
        addSubview(voiceButton)
        voiceButton.constrain(width: 33, height: 33)
        voiceButton.align(.right, inset: 10)
        voiceButton.align(.bottom, inset: 40)
        addSubview(progressView)
        progressView.align(.left, inset: 0)
        progressView.align(.right, inset: 0).priority = UILayoutPriority.defaultHigh
        progressView.align(.bottom)
        progressView.constrain(height: 3)
        addSubview(timeLabel)
        timeLabel.align(.right, inset: 10)
        timeLabel.align(.bottom, inset: 6)
        addSubview(noPlayMask)
        noPlayMask.fill(in: self)
        addSubview(playerButton)
        playerButton.constrain(width: 80, height: 80)
        playerButton.center(to: self)
    }
    override func playTimeDidChange(currentTime: TimeInterval, totalTime: TimeInterval) {
        DispatchQueue.main.async {
            let surplusText = SweetPlayerView.formatSecondsToString(totalTime - currentTime)
            self.timeLabel.text = surplusText
            self.progressView.progress = Float(currentTime / totalTime)
        }
    }
    override func playStateDidChange(isPlaying: Bool) {
        player?.placeholderImageView.isHidden = isPlaying
        playerButton.isHidden = isPlaying
        noPlayMask.isHidden = isPlaying
    }

}
