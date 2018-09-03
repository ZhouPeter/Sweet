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
    
    private let domainLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(hex: 0xcccccc)
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "domain.com"
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.cornerRadius = 3
        imageView.backgroundColor = UIColor(hex: 0xD8D8D8)
        return imageView
    } ()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? ArticleMessageContent else { return }
        titleLabel.text = content.title
        domainLabel.text = URL(string: content.articleURL)?.host ?? ""
        imageView.sd_setImage(with: URL(string: content.thumbnailURL)?.imageView2(size: imageView.bounds.size))
        showLoading(false)
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(imageView)
        mediaContainerView.addSubview(titleLabel)
        mediaContainerView.addSubview(domainLabel)
        titleLabel.align(.left, to: mediaContainerView, inset: 10)
        titleLabel.align(.top, to: mediaContainerView, inset: 10)
        titleLabel.align(.right, to: mediaContainerView, inset: 10)
        titleLabel.constrain(height: 40)
        imageView.constrain(width: 32, height: 32)
        imageView.align(.bottom, to: mediaContainerView, inset: 5)
        imageView.align(.right, to: mediaContainerView, inset: 5)
        domainLabel.constrain(height: 15)
        domainLabel.align(.left, to: titleLabel)
        domainLabel.align(.right, to: imageView)
        domainLabel.align(.top, to: imageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
    }
}
