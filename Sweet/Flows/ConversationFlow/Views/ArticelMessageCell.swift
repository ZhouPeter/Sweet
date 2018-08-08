//
//  ArticelMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/27.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

final class ArticleMessageCell: MediaMessageCell {
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "世界上的女明星那么多，你偏偏喜欢国内的。那么，你是喜欢杨幂还是柳岩呢？"
        label.numberOfLines = 2
        return label
    } ()
    
    private let contentTextView: UITextView = {
        let textView = UITextView()
        textView.isEditable = false
        textView.isScrollEnabled = false
        textView.textColor = .black
        textView.backgroundColor = UIColor(hex: 0xd8d8d8)
        return textView
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        return imageView
    } ()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? ArticleMessageContent else { return }
        titleLabel.text = content.title
        contentTextView.text = content.content
        imageView.sd_setImage(with: URL(string: content.thumbnailURL)?.imageView2(size: imageView.bounds.size))
        showLoading(false)
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(imageView)
        mediaContainerView.addSubview(titleLabel)
        mediaContainerView.addSubview(contentTextView)
        imageView.constrain(width: 40, height: 40)
        imageView.align(.left, to: mediaContainerView, inset: 10)
        imageView.align(.top, to: mediaContainerView, inset: 10)
        titleLabel.align(.top, to: imageView)
        titleLabel.pin(.right, to: imageView, spacing: 10)
        titleLabel.align(.right, to: mediaContainerView, inset: 10)
        contentTextView.align(.left)
        contentTextView.align(.right)
        contentTextView.align(.bottom)
        contentTextView.pin(.bottom, to: imageView, spacing: 10)
    }
}
