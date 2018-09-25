//
//  ContentCardMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit
final class ContentCardMessageCell: MediaMessageCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.text = "世界上的女明星那么多，你偏偏喜欢国内的。那么，你是喜欢杨幂还是柳岩呢？"
        label.numberOfLines = 3
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.backgroundColor = UIColor(hex: 0xdedede)
        return imageView
    } ()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? ContentCardContent else { return }
        label.attributedText = content.text.getHtmlAttributedString(font: label.font, textColor: .black, lineSpacing: 0)
        imageView.sd_setImage(with: URL(string: content.imageURLString)?.imageView2(size: imageView.bounds.size))
        showLoading(false)
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(label)
        label.align(.left, inset: 10)
        label.align(.top, inset: 6)
        label.align(.right, inset: 10)
        label.constrain(height: 60)
        mediaContainerView.addSubview(imageView)
        imageView.align(.left)
        imageView.align(.right)
        imageView.pin(.bottom, to: label)
        imageView.align(.bottom)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        imageView.image = nil
        imageView.sd_cancelCurrentImageLoad()
        showLoading(true)
    }
}
