//
//  OptionCardMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class OptionCardMessageCell: MessageContentCell {
    private let indicator = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
    private let label: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.preferredFont(forTextStyle: .body)
        label.text = "世界上的女明星那么多，你偏偏喜欢国内的。那么，你是喜欢杨幂还是柳岩呢？"
        return label
    } ()
    
    private let leftOptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "Avatar")
        return imageView
    } ()
    
    private let rightOptionImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.image = #imageLiteral(resourceName: "Avatar")
        return imageView
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func configure(
        with message: MessageType,
        at indexPath: IndexPath,
        and messagesCollectionView: MessagesCollectionView) {
        
    }
    
    private func setup() {
        messageContainerView.addSubview(label)
        label.align(.left, inset: 10)
        label.align(.top, inset: 6)
        label.align(.right, inset: 10)
        messageContainerView.addSubview(leftOptionImageView)
        leftOptionImageView.align(.left)
        leftOptionImageView.align(.right)
        leftOptionImageView.pin(.bottom, to: label, spacing: 6)
        leftOptionImageView.align(.bottom)
        messageContainerView.addSubview(rightOptionImageView)
        rightOptionImageView.align(.left, to: leftOptionImageView)
        rightOptionImageView.align(.right)
        rightOptionImageView.align(.top, to: leftOptionImageView)
        rightOptionImageView.align(.bottom)
        messageContainerView.addSubview(indicator)
        indicator.fill(in: messageContainerView)
    }
    
    private func showLoading(_ isLoading: Bool) {
        if isLoading {
            indicator.startAnimating()
            indicator.isHidden = false
            label.isHidden = true
            leftOptionImageView.isHidden = true
        }
    }
}
