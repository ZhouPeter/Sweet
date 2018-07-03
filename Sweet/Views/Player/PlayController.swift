//
//  PlayController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
import Hero
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
        view.hero.isEnabled = true
        view.hero.id = resource?.definitions[0].url.absoluteString
        let pan = PanGestureRecognizer(direction: .vertical, target: self, action: #selector(didPan(_:)))
        pan.require(toFail: playView.panGesture)
        view.addGestureRecognizer(pan)
    }
    
    @objc private func didPan(_ gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let progress = translation.y / view.bounds.height
        switch gesture.state {
        case .began:
            logger.debug()
            dismiss(animated: true, completion: nil)
        case .changed:
            Hero.shared.update(progress)
            let currentPos = CGPoint(x: translation.x + view.center.x, y: translation.y + view.center.y)
            Hero.shared.apply(modifiers: [.position(currentPos)], to: view)
        default:
            if progress + gesture.velocity(in: nil).y / view.bounds.height > 0.3 {
                Hero.shared.finish()
            } else {
                Hero.shared.cancel()
            }
        }
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
