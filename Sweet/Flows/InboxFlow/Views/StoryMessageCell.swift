//
//  StoryMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class StoryMessageCell: MessageContentCell {
    private lazy var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
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
    
    private func setup() {
        messageContainerView.backgroundColor = .black
        messageContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.fill(in: contentView)
        
        let maskView = UIView()
        maskView.backgroundColor = .black
        maskView.alpha = 0.5
        messageContainerView.addSubview(maskView)
        maskView.fill(in: contentView)
        
        let playView = UIImageView()
        playView.image = #imageLiteral(resourceName: "StoryMessagePlay")
        messageContainerView.addSubview(playView)
        playView.constrain(width: 40, height: 40)
        playView.center(to: messageContainerView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}
