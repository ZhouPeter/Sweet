//
//  StoryMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import Kingfisher

final class StoryMessageCell: MediaMessageCell {
    lazy var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    } ()
    private let videoMaskView = UIView()
    private let playView = UIImageView()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? StoryMessageContent else { return }
        thumbnailImageView.kf.setImage(with: content.thumbnailURL()) { [weak self] (_, _, _, _) in
            self?.showLoading(false)
        }
        if content.storyType == .video || content.storyType == .poke {
            videoMaskView.isHidden = false
            playView.isHidden = false
        } else {
            videoMaskView.isHidden = true
            playView.isHidden = true
        }
    }
    
    override func setup() {
        super.setup()
        
        mediaContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.fill(in: mediaContainerView)
        
        videoMaskView.backgroundColor = .black
        videoMaskView.alpha = 0.5
        mediaContainerView.addSubview(videoMaskView)
        videoMaskView.fill(in: mediaContainerView)
        
        playView.image = #imageLiteral(resourceName: "StoryMessagePlay")
        mediaContainerView.addSubview(playView)
        playView.constrain(width: 40, height: 40)
        playView.center(to: mediaContainerView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
        thumbnailImageView.kf.cancelDownloadTask()
    }
}
