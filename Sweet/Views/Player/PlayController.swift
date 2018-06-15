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
    private var videoSize: CGSize = CGSize(width: UIScreen.mainWidth(), height: UIScreen.mainWidth() * 9 / 16)
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
            loadItemValues()
        }
        let recognizer = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipeDown))
        recognizer.require(toFail: playView.panGesture)
        recognizer.direction = .down
        view.addGestureRecognizer(recognizer)
        
    }
    
    private func loadItemValues() {
        if let resource = resource {
            let asset = resource.definitions[0].avURLAsset
            asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                DispatchQueue.main.async {
                    if asset.isPlayable {
                        self.loadedResourceForPlay(asset: asset)
                    }
                }
            }
        }
    }
    
    private func loadedResourceForPlay(asset: AVAsset) {
        let tracks = asset.tracks
        for track in tracks where track.mediaType  == .video {
            let naturalSize = track.naturalSize
            let scaleX = naturalSize.width / UIScreen.mainWidth()
            let scaleY = naturalSize.height / UIScreen.mainHeight()
            if scaleX > scaleY {
                videoSize = CGSize(width: UIScreen.mainWidth(),
                                   height: UIScreen.mainWidth() * naturalSize.height / naturalSize.width)
                playView.frame = CGRect(origin: .zero, size: videoSize)
                playView.center = view.center
            } else {
                videoSize = CGSize(width: UIScreen.mainHeight() * naturalSize.width / naturalSize.height,
                                   height: UIScreen.mainHeight())
                playView.frame = CGRect(origin: .zero, size: videoSize)
                playView.center = view.center
            }
        }
    }
    
    private func setupUI() {
        view.addSubview(playView)
        playView.frame = CGRect(origin: .zero, size: videoSize)
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
    @objc private func handleSwipeDown() {
        allowRotation = false
        self.dismiss(animated: true, completion: nil)
    }
}

extension PlayController: SweetPlayerViewDelegate {
    func sweetPlayerSwipeDown() {
        allowRotation = false
        self.dismiss(animated: true, completion: nil)
    }
    func sweetPlayer(player: SweetPlayerView, playerOrientChanged isFullscreen: Bool) {
        if isFullscreen {
            playView.frame = self.view.bounds
            backButton.isHidden = true
        } else {
            playView.frame = CGRect(origin: .zero, size: videoSize)
            playView.center = view.center
            backButton.isHidden = false
        }
    }
}
