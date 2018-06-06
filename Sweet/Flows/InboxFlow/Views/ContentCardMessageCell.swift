//
//  ContentCardMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit
import Kingfisher

final class ContentCardMessageCell: MediaMessageCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "世界上的女明星那么多，你偏偏喜欢国内的。那么，你是喜欢杨幂还是柳岩呢？"
        label.numberOfLines = 0
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "Avatar")
        return imageView
    } ()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? ContentCardContent else { return }
        label.text = content.text
        imageView.kf.setImage(with: URL(string: content.imageURLString))
        showLoading(false)
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(label)
        label.align(.left, inset: 10)
        label.align(.top, inset: 6)
        label.align(.right, inset: 10)
        mediaContainerView.addSubview(imageView)
        imageView.align(.left)
        imageView.align(.right)
        imageView.pin(.bottom, to: label, spacing: 6)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
        imageView.kf.cancelDownloadTask()
        showLoading(true)
    }
}
