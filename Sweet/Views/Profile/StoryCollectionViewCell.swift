//
//  StoryCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage
class StoryCollectionViewCell: UICollectionViewCell {
    private lazy var pokeView = StorySmallPokeView()
    private lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0.15, alpha: 1)
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
    
    private lazy var effectView: UIVisualEffectView = {
        let blurEffect = UIBlurEffect(style: .light)
        let effectView = UIVisualEffectView(effect: blurEffect)
        return effectView
    }()
    
    private lazy var commentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.enableShadow()
        return label
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = ""
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(storyImageView)
        storyImageView.fill(in: contentView)
        storyImageView.addSubview(effectView)
        effectView.fill(in: storyImageView)
        contentView.addSubview(commentLabel)
        commentLabel.align(.left, inset: 5, priority: .defaultHigh)
        commentLabel.align(.right, inset: 5, priority: .defaultHigh)
        commentLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        commentLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
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
            effectView.alpha = 0
            if viewModel.type == .video {
                storyImageView.setAnimationImages(withVideoURL: videoURL, animationDuration: 0.5, count: 3, size: storyImageView.frame.size)
            } else if viewModel.type == .poke {
                storyImageView.sd_setImage(with: videoURL.videoThumbnail(size: storyImageView.frame.size))
                pokeView.center = CGPoint(x: frame.width / 2 + viewModel.pokeCenter.x * frame.width,
                                          y: frame.height / 2 + viewModel.pokeCenter.y * frame.height)
                pokeView.isHidden = false
            }
        } else if let imageURL = viewModel.imageURL {
            storyImageView.sd_setImage(with: imageURL) { (image, _, _, _) in
                if viewModel.type == .share {
                    self.effectView.alpha = 1
                    self.commentLabel.text = viewModel.commentString
                } else {
                    self.effectView.alpha = 0
                }
            }
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
