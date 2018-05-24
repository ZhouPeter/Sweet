//
//  PlayController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
class PlayController: UIViewController {
    var avPlayer: AVPlayer?
    var resource: SweetPlayerResource?
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Return"), for: .normal)
        button.addTarget(self, action: #selector(backAction), for: .touchUpInside)
        return button
    }()
    
    lazy var playView: SweetPlayerView = {
        let playView = SweetPlayerView.init(controlView: SweetPlayerControlView())
        playView.delegate = self
        playView.isHasVolume = true
        return playView
    }()
    
    deinit {
        logger.debug("释放播放器")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        if let player = avPlayer, let resource = resource {
            playView.resource = resource
            playView.setAVPlayer(player: player)
        }
    }
    
    private func setupUI() {
        view.addSubview(playView)
        playView.frame = CGRect(x: 0, y: 0,
                                width: UIScreen.mainWidth(),
                                height: UIScreen.mainWidth() * 9 / 16)
        playView.center = view.center
        view.addSubview(backButton)
        backButton.align(.left, to: view, inset: 10)
        backButton.align(.top, to: view, inset: UIScreen.isIphoneX() ? 54 : 20)
        backButton.constrain(width: 40, height: 40)

    }
    
    func updatePlayView(player: AVPlayer) {
        playView.avPlayer = player
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        allowRotation = true
    }
    
    override func  viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        allowRotation = false
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    @objc private func backAction() {
        allowRotation = false
        self.dismiss(animated: true, completion: nil)
    }
}

extension PlayController: SweetPlayerViewDelegate {
    func sweetPlayer(player: SweetPlayerView, playerStateDidChange state: SweetPlayerState) {
    
    }
    
    func sweetPlayer(player: SweetPlayerView,
                     loadedTimeDidChange loadedDuration: TimeInterval,
                     totalDuration: TimeInterval) {
        
    }
    
    func sweetPlayer(player: SweetPlayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        
    }
    
    func sweetPlayer(player: SweetPlayerView, playerIsPlaying playing: Bool) {
        
    }
    
    func sweetPlayer(player: SweetPlayerView, playerOrientChanged isFullscreen: Bool) {
        if isFullscreen {
            playView.frame = self.view.bounds
            backButton.isHidden = true
        } else {
            playView.frame = CGRect(x: 0, y: 0,
                                    width: UIScreen.mainWidth(),
                                    height: UIScreen.mainWidth() * 9 / 16)
            playView.center = view.center
            backButton.isHidden = false
        }
    }
}
