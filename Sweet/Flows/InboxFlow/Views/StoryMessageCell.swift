//
//  StoryMessageCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class StoryMessageCell: MediaMessageCell {
    private lazy var thumbnailImageView: UIImageView = {
        let view = UIImageView()
        view.contentMode = .scaleAspectFill
        return view
    } ()
    
    override func setup() {
        super.setup()
        
        mediaContainerView.addSubview(thumbnailImageView)
        thumbnailImageView.fill(in: mediaContainerView)
        
        let maskView = UIView()
        maskView.backgroundColor = .black
        maskView.alpha = 0.5
        mediaContainerView.addSubview(maskView)
        maskView.fill(in: mediaContainerView)
        
        let playView = UIImageView()
        playView.image = #imageLiteral(resourceName: "StoryMessagePlay")
        mediaContainerView.addSubview(playView)
        playView.constrain(width: 40, height: 40)
        playView.center(to: mediaContainerView)
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        thumbnailImageView.image = nil
    }
}
