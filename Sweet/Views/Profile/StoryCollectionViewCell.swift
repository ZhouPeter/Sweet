//
//  StoryCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Kingfisher
class StoryCollectionViewCell: UICollectionViewCell {
    private lazy var storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var recoveryImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    
    private lazy var recoveryLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = .white
        return label
    }()
    
    override var isSelected: Bool {
        set {}
        get { return super.isSelected}
    }
    
    override var isHighlighted: Bool {
        set {}
        get { return super.isHighlighted }
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storyImageView)
        storyImageView.fill(in: contentView)
        contentView.addSubview(recoveryImageView)
        recoveryImageView.align(.left, to: contentView, inset: 10)
        recoveryImageView.align(.bottom, to: contentView, inset: 10)
        recoveryImageView.constrain(width: 20, height: 20)
        contentView.addSubview(recoveryLabel)
        recoveryLabel.centerY(to: recoveryImageView)
        recoveryLabel.pin(.right, to: recoveryImageView)
    
    }
    
    func update(viewModel: StoryCellViewModel) {
        storyImageView.image = nil
        storyImageView.animationImages = nil
        storyImageView.stopAnimating()
        if let videoURL = viewModel.videoURL {
            storyImageView.setAnimationImages(url: videoURL, animationDuration: 0.5, count: 3)
        } else if let imageURL = viewModel.imageURL {
            storyImageView.kf.setImage(with: imageURL)
        }
        if viewModel.created/1000 + 72 * 3600 < Int(Date().timeIntervalSince1970) {
            recoveryImageView.isHidden = false
            recoveryLabel.isHidden = false
            recoveryImageView.image = #imageLiteral(resourceName: "SelfVisual")
            recoveryLabel.text =  "仅自己可见"
        } else {
            recoveryImageView.isHidden = true
            recoveryLabel.isHidden = true
        }
    }
}
