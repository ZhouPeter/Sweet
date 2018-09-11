//
//  UserCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol UserCardCollectionViewCellDelegate: NSObjectProtocol {
    func showStoriesPlayerController(cell: UserCardCollectionViewCell)
    func showInputTextView(cell: UserCardCollectionViewCell)
}
class UserCardCollectionViewCell: UICollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = UserCardViewModel
    weak var delegate: UserCardCollectionViewCellDelegate?
    private var viewModel: ViewModelType?
    func updateWith(_ viewModel: UserCardViewModel) {
        self.viewModel = viewModel
        coverImageView.image = nil
        coverImageView.animationImages = nil
        coverImageView.stopAnimating()
        if let preferenceImageURL = viewModel.preferenceImageURL {
            coverImageView.sd_setImage(with: preferenceImageURL)
            bottomButton.setTitle("给我点赞", for: .normal)
            bottomButton.setImage(#imageLiteral(resourceName: "StarWhite"), for: .normal)
            bottomButton.setImageRight(space: 0)
            bottomButton.addTarget(self, action: #selector(likeAction(_:)), for: .touchUpInside)
        } else if let viewModels = viewModel.storyViewModels, viewModels.count > 0 {
            let viewModel = viewModels[0]
            if let videoURL = viewModel.videoURL {
                if viewModel.type == .poke {
                    coverImageView.sd_setImage(with: videoURL.videoThumbnail(size: coverImageView.frame.size))
                } else {
                    coverImageView.setAnimationImages(withVideoURL: videoURL, animationDuration: 0.5, count: 3, size: coverImageView.frame.size)
                }
            } else if let imageURL = viewModel.imageURL {
                coverImageView.sd_setImage(with: imageURL)
            }
            bottomButton.setImage(nil, for: .normal)
            bottomButton.setTitle("查看小故事", for: .normal)
            bottomButton.resetEdgeInsets()
            bottomButton.addTarget(self, action: #selector(showStoryAction(_:)), for: .touchUpInside)
        }
        avatarImageView.sd_setImage(with: viewModel.avatarURL)
        nameLabel.text = viewModel.nicknameString
        universityLabel.text = viewModel.unviersityString
        commonContactLabel.text = viewModel.commonContactString
        preferenceLabel.text = viewModel.commentString

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
    
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 14)
        label.textColor = .white
        return label
    }()
    
    private lazy var universityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private  lazy var commonContactLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private lazy var preferenceLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 10)
        label.textColor = .white
        return label
    }()
    
    private lazy var bottomButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.xpNavBlue()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14)
        button.layer.cornerRadius = 5
        button.clipsToBounds = true
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        contentView.clipsToBounds = true
        coverMaskView.layer.cornerRadius = 5
        coverMaskView.layer.borderColor = UIColor(hex: 0xF2F2F2).cgColor
        coverMaskView.layer.borderWidth = 0.5
        coverImageView.layer.cornerRadius = 5
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        bottomButton.removeTarget(self, action: nil, for: .allEvents)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(coverMaskView)
        coverMaskView.fill(in: contentView)
        contentView.addSubview(coverImageView)
        coverImageView.fill(in: contentView)
        contentView.addSubview(bottomButton)
        bottomButton.constrain(width: 120, height: 36)
        bottomButton.align(.bottom, inset: 8)
        bottomButton.centerX(to: contentView)
        contentView.addSubview(preferenceLabel)
        preferenceLabel.pin(.top, to: bottomButton, spacing: 16)
        preferenceLabel.centerX(to: contentView)
        contentView.addSubview(commonContactLabel)
        commonContactLabel.centerX(to: contentView)
        commonContactLabel.pin(.top, to: preferenceLabel)
        contentView.addSubview(universityLabel)
        universityLabel.centerX(to: contentView)
        universityLabel.pin(.top, to: commonContactLabel)
        contentView.addSubview(nameLabel)
        nameLabel.centerX(to: contentView)
        nameLabel.pin(.top, to: universityLabel)
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 60, height: 60)
        avatarImageView.centerX(to: contentView)
        avatarImageView.pin(.top, to: nameLabel, spacing: 8)
        avatarImageView.setViewRounded(borderWidth: 1, borderColor: UIColor(hex: 0xF2F2F2))
    }

    
    @objc private func likeAction(_ sender: UIButton) {
       delegate?.showInputTextView(cell: self)
    }
    
    @objc private func showStoryAction(_ sender: UIButton) {
        delegate?.showStoriesPlayerController(cell: self)
    }
    
}
