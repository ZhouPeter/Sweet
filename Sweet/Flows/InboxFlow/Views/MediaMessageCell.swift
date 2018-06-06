//
//  MediaMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import MessageKit

class MediaMessageCell: MessageContentCell {
    let activityIndicator = UIActivityIndicatorView(activityIndicatorStyle: .white)
    let activityIndicatorContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightGray
        return view
    } ()
    
    let mediaContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    } ()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    func setup() {
        messageContainerView.addSubview(activityIndicatorContainerView)
        activityIndicatorContainerView.fill(in: messageContainerView)
        activityIndicatorContainerView.addSubview(activityIndicator)
        activityIndicator.fill(in: messageContainerView)
        messageContainerView.addSubview(mediaContainerView)
        mediaContainerView.fill(in: messageContainerView)
        showLoading(true)
    }
    
    func showLoading(_ isLoading: Bool) {
        if isLoading {
            mediaContainerView.isHidden = true
            activityIndicatorContainerView.isHidden = false
            activityIndicator.startAnimating()
        } else {
            mediaContainerView.isHidden = false
            activityIndicatorContainerView.isHidden = true
            activityIndicator.stopAnimating()
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        showLoading(true)
    }
}
