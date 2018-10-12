//
//  ContentCardMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class ContentCardMessageCell: MediaMessageCell {
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 15)
        label.numberOfLines = 3
        return label
    } ()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = UIColor(hex: 0xdedede)
        return imageView
    } ()
    
    private var message: MessageType?
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        super.configure(with: message, at: indexPath, and: messagesCollectionView)
        guard case let .custom(value) = message.kind, let content = value as? ContentCardContent else { return }
        self.message = message
        let url = URL(string: content.imageURLString)?.imageView2(size: imageView.bounds.size)
        showLoading(true)
        imageView.sd_setImage(with: url) { [weak self] (_, _, _, _) in
            self?.showLoading(false)
        }
    }
    
    func configureAttributedText(callback: @escaping (NSAttributedString?) -> Void) {
        guard let message = message else { return }
        guard case let .custom(value) = message.kind, let content = value as? ContentCardContent else { return }
        content.text.converHTMLToAttributedString(font: label.font, textColor: .black) { [weak self] (text, attributedString) in
            self?.label.attributedText = attributedString
            callback(attributedString)
        }
    }
    
    func configure(attributedText: NSAttributedString) {
        label.attributedText = attributedText
    }
    
    override func setup() {
        super.setup()
        mediaContainerView.backgroundColor = .white
        mediaContainerView.addSubview(imageView)
        let labelBackView = UIView()
        labelBackView.backgroundColor = .white
        mediaContainerView.addSubview(labelBackView)
        mediaContainerView.addSubview(label)
        imageView.align(.left)
        imageView.align(.right)
        imageView.pin(.bottom, to: label)
        imageView.align(.bottom)
        labelBackView.align(.left)
        labelBackView.align(.right)
        labelBackView.align(.top)
        labelBackView.align(.bottom, to: label)
        label.align(.left, inset: 10)
        label.align(.top, inset: 6)
        label.align(.right, inset: 10)
        label.constrain(height: 60)
    }
}
