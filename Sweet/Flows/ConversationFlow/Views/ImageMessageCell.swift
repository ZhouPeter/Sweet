//
//  ImageMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/12.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import MessageKit
import Kingfisher

final class ImageMessageCell: MediaMessageCell {
    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "Logo")
        return imageView
    } ()
    
    override func setup() {
        super.setup()
        mediaContainerView.addSubview(imageView)
        imageView.fill(in: mediaContainerView)
    }
    
    override func configure(
        with message: MessageType, at indexPath: IndexPath, and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        mediaContainerView.backgroundColor = .black
        messageContainerView.backgroundColor = .clear
        guard case let .custom(value) = message.kind, let content = value as? ImageMessageContent else { return }
        imageView.kf
            .setImage(
                with: URL(string: content.url)?.imageView2(size: imageView.bounds.size)
            ) { [weak self] (_, _, _, _) in
                self?.mediaContainerView.backgroundColor = .clear
                self?.showLoading(false)
        }
    }
}
