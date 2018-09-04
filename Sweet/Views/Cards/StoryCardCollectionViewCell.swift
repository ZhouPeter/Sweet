//
//  StoryCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage
class StoryCardCollectionViewCell: UICollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = StoryCollectionViewCellModel
    private var viewModel: ViewModelType?
    func updateWith(_ viewModel: StoryCollectionViewCellModel) {
        self.viewModel = viewModel
        coverImageView.image = nil
        coverImageView.animationImages = nil
        coverImageView.stopAnimating()
        if let videoURL = viewModel.videoURL {
            effectView.alpha = 0
            if viewModel.type == .poke {
                coverImageView.sd_setImage(with: videoURL.videoThumbnail(size: coverImageView.frame.size))
                pokeView.isHidden = false
                let centerX = viewModel.pokeCenter.x * contentView.bounds.width
                let centerY = viewModel.pokeCenter.y * contentView.bounds.height
                pokeViewCenterXConstraint?.constant = centerX
                pokeViewCenterYConstraint?.constant = centerY
            } else {
                coverImageView.setAnimationImages(withVideoURL: videoURL, animationDuration: 0.5, count: 3, size: coverImageView.frame.size)
                pokeView.isHidden = true
            }
        } else {
            coverImageView.sd_setImage(with: viewModel.imageURL) { (image, _, _, _) in
                if viewModel.type == .share {
                    self.effectView.alpha = 1
                    self.commentLabel.text = viewModel.commentString
                } else {
                    self.effectView.alpha = 0
                }
            }
            pokeView.isHidden = true
        }
        avatarImageView.sd_setImage(with: viewModel.avatarImageURL)
        nameLabel.text = viewModel.name
        avatarCirCleImageView.image = viewModel.isRead ? #imageLiteral(resourceName: "StoryRead") : #imageLiteral(resourceName: "StoryUnread")
    }
    
    private lazy var coverMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = .black
        return view
    }()
    
    private lazy var coverImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var pokeView: StorySmallPokeView = {
        let pokeView = StorySmallPokeView()
        pokeView.isHidden = true
        return pokeView
    }()
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    }()
    private lazy var avatarCirCleImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = #imageLiteral(resourceName: "StoryUnread")
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.textColor = .white
        return label
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
        return label
    }()
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        coverMaskView.layer.cornerRadius = 5
        coverMaskView.layer.borderColor = UIColor(hex: 0xF2F2F2).cgColor
        coverMaskView.layer.borderWidth = 0.5
        coverImageView.layer.cornerRadius = 5
        avatarImageView.layer.cornerRadius = 24
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        commentLabel.text = ""
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var pokeViewCenterXConstraint: NSLayoutConstraint?
    private var pokeViewCenterYConstraint: NSLayoutConstraint?
    
    private func setupUI() {
        contentView.addSubview(coverMaskView)
        coverMaskView.fill(in: contentView)
        contentView.addSubview(coverImageView)
        coverImageView.fill(in: contentView)
        effectView.fill(in: coverImageView)
        contentView.addSubview(commentLabel)
        commentLabel.align(.left, inset: 5)
        commentLabel.align(.right, inset: 5)
        commentLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.25).isActive = true
        commentLabel.bottomAnchor.constraint(equalTo: contentView.centerYAnchor, constant: 0).isActive = true
        contentView.addSubview(pokeView)
        pokeView.constrain(width: 50, height: 50)
        pokeViewCenterXConstraint = pokeView.centerX(to: contentView)
        pokeViewCenterYConstraint = pokeView.centerY(to: contentView)
        contentView.addSubview(nameLabel)
        nameLabel.centerX(to: contentView)
        nameLabel.align(.bottom, inset: 5)
        contentView.addSubview(avatarCirCleImageView)
        avatarCirCleImageView.constrain(width: 50, height: 50)
        avatarCirCleImageView.centerX(to: contentView)
        avatarCirCleImageView.pin(.top, to: nameLabel)
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 46, height: 46)
        avatarImageView.center(to: avatarCirCleImageView)
    }
    
    @objc private func didTapAvatar(_ tap: UITapGestureRecognizer) {
        if let viewModel = viewModel {
            viewModel.callback?(viewModel.sourceUserId)
        }
    }

}
