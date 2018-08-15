//
//  VideoCardPlayerManager.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
class VideoCardPlayerManager: NSObject {
    static let shared = VideoCardPlayerManager()
    private override init() {
        super.init()
    }
    
    var player: AVPlayer?
    private var assetURL: URL?
    private var asset: AVAsset?
    private var playerItem: AVPlayerItem?
    private var status = AVPlayerItemStatus.unknown
    
    func play(with url: URL) {
        guard assetURL != url else {
            if status == .readyToPlay {
                player?.play()
            }
            return
        }
        clean()
        assetURL = url
        prepareToPlay()
    }
    
    func pause() {
        logger.debug()
        player?.pause()
    }
    
    private func prepareToPlay() {
        guard let url = assetURL else { return }
        let asset = SweetPlayerManager.assetNoCache(for: url)
        let assetKeys = [
            "playable",
            "duration"
        ]
        let item = AVPlayerItem(asset: asset, automaticallyLoadedAssetKeys: assetKeys)
        playerItem = item
        player = AVPlayer(playerItem: playerItem)
    }
    
    private func clean() {
        player?.pause()
        player?.replaceCurrentItem(with: nil)
        player = nil
        playerItem = nil
        status = .unknown
    }

}
