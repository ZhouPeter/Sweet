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
    private lazy var pokeView = StorySmallPokeView()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0.15, alpha: 1)
        label.font = UIFont.systemFont(ofSize: 14)
        label.backgroundColor = .white
        label.textAlignment = .center
        label.layer.cornerRadius = 2
        label.layer.masksToBounds = true
        label.numberOfLines = 2

        return label
    }()
    
    lazy var storyImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isHighlighted = false
        return imageView
    }()
    
    private lazy var recoveryImageView = UIImageView()
    
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
        get { return super.isHighlighted}
    }
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        contentView.clipsToBounds = true
        contentView.backgroundColor = .clear
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storyImageView)
        storyImageView.fill(in: contentView)
        contentView.addSubview(timeLabel)
        timeLabel.align(.left, inset: 5)
        timeLabel.align(.top, inset: 5)
        timeLabel.constrain(width: 40, height: 40)
        contentView.addSubview(recoveryImageView)
        recoveryImageView.align(.left, to: contentView, inset: 10)
        recoveryImageView.align(.bottom, to: contentView, inset: 10)
        recoveryImageView.constrain(width: 20, height: 20)
        contentView.addSubview(recoveryLabel)
        recoveryLabel.centerY(to: recoveryImageView)
        recoveryLabel.pin(.right, to: recoveryImageView)
        contentView.addSubview(pokeView)
        pokeView.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
    }
    
    func update(viewModel: StoryCellViewModel) {
        pokeView.isHidden = true
        storyImageView.image = nil
        storyImageView.animationImages = nil
        storyImageView.stopAnimating()
        if let videoURL = viewModel.videoURL {
            if viewModel.type == .video {
                storyImageView.setAnimationImages(url: videoURL, animationDuration: 0.5, count: 3)
            } else if viewModel.type == .poke {
                storyImageView.kf.setImage(with: videoURL.videoThumbnail(size: storyImageView.frame.size))
                pokeView.center = CGPoint(x: frame.width / 2 + viewModel.pokeCenter.x * frame.width,
                                          y: frame.height / 2 + viewModel.pokeCenter.y * frame.height)
                pokeView.isHidden = false
            }
        } else if let imageURL = viewModel.imageURL {
            storyImageView.kf.setImage(with: imageURL)
        }
        if viewModel.timestampString == ""  {
            timeLabel.isHidden = true
        } else {
            let attributedString = NSMutableAttributedString(string: viewModel.timestampString)
            attributedString.addAttributes([NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18)],
                                           range: NSRange(location: 0, length: 2))
            let monthLength = attributedString.length - 3
            attributedString.addAttributes([NSAttributedStringKey.font: UIFont.systemFont(ofSize: 10)],
                                           range: NSRange(location: 3, length: monthLength))
            timeLabel.attributedText = attributedString
            timeLabel.isHidden = false
        }
        if viewModel.created/1000 + 72 * 3600 < Int(Date().timeIntervalSince1970) {
            recoveryImageView.isHidden = false
            recoveryLabel.isHidden = false
            recoveryImageView.image = #imageLiteral(resourceName: "SelfVisual")
            recoveryLabel.text =  viewModel.visualText
        } else {
            recoveryImageView.isHidden = true
            recoveryLabel.isHidden = true
        }
    }
}
