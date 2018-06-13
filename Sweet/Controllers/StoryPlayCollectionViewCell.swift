//
//  StoryCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Gemini
class StoryPlayCollectionViewCell: GeminiCell {
    private lazy var placeholderView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var blackShadowView: UIView = {
        let view = UIView()
        return view
    }()
    
    override var shadowView: UIView? {
        return blackShadowView
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(placeholderView)
        placeholderView.fill(in: contentView)
        contentView.addSubview(blackShadowView)
        blackShadowView.fill(in: contentView)
    }
    
    func setPlaceholderContentView(view: UIView) {
        if placeholderView.superview != nil {
            placeholderView.removeFromSuperview()
        }
        placeholderView = view
        contentView.addSubview(placeholderView)
        placeholderView.fill(in: contentView)
    }
}
