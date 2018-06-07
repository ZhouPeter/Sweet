//
//  OptionCardMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import Kingfisher

final class OptionCardMessageCell: MediaMessageCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "世界上的女明星那么多，你偏偏喜欢国内的。那么，你是喜欢杨幂还是柳岩呢？"
        label.numberOfLines = 0
        return label
    } ()
    
    private let leftOptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "Avatar")
        return imageView
    } ()
    
    private let rightOptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.image = #imageLiteral(resourceName: "Avatar")
        return imageView
    } ()
    
    private let leftResultView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "SelectedChoice")
        return imageView
    } ()
    
    private let rightResultView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "SelectedChoice")
        return imageView
    } ()
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? OptionCardContent else { return }
        label.text = content.text
        leftOptionImageView.kf.setImage(with: URL(string: content.leftImageURLString))
        rightOptionImageView.kf.setImage(with: URL(string: content.rightImageURLString))
        leftResultView.isHidden = content.result != .left
        rightResultView.isHidden = content.result != .right
        showLoading(false)
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(label)
        label.align(.left, inset: 10)
        label.align(.top, inset: 6)
        label.align(.right, inset: 10)
        mediaContainerView.addSubview(leftOptionImageView)
        leftOptionImageView.align(.left)
        leftOptionImageView.constrain(height: 140)
        leftOptionImageView.pin(.bottom, to: label, spacing: 6)
        mediaContainerView.addSubview(rightOptionImageView)
        rightOptionImageView.pin(.right, to: leftOptionImageView)
        rightOptionImageView.align(.right)
        rightOptionImageView.align(.top, to: leftOptionImageView)
        rightOptionImageView.align(.bottom, to: leftOptionImageView)
        rightOptionImageView.equal(.width, to: leftOptionImageView)
        mediaContainerView.addSubview(leftResultView)
        leftResultView.constrain(width: 30, height: 30)
        leftResultView.center(to: leftOptionImageView)
        mediaContainerView.addSubview(rightResultView)
        rightResultView.constrain(width: 30, height: 30)
        rightResultView.center(to: rightOptionImageView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        label.text = nil
        leftOptionImageView.image = nil
        rightOptionImageView.image = nil
        leftOptionImageView.kf.cancelDownloadTask()
        rightOptionImageView.kf.cancelDownloadTask()
        showLoading(true)
    }
}
