//
//  StoryCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Kingfisher
class StoryCardCollectionViewCell: UICollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = StoryCollectionViewCellModel
    func updateWith(_ viewModel: StoryCollectionViewCellModel) {
        coverImageView.image = nil
        coverImageView.animationImages = nil
        let animationDuration: TimeInterval = 0.5
        let count = 3
        var urls = [URL]()
        if let videoURL = viewModel.videoURL {
            let url = videoURL.absoluteString
            for index in 0 ..< count {
                let time = 0.5/Double(count) * Double(index + 1)
                let width = Int(UIScreen.mainWidth()/3)
                let height = Int(UIScreen.mainHeight()/3)
                let urlParematers = url
                    + "?vframe/jpg/offset/\(time)/w/\(width)/h/\(height)"
                let url = URL(string: urlParematers)!
                urls.append(url)
            }
            var images = [UIImage]()
            let group = DispatchGroup()
            urls.forEach { (url) in
                group.enter()
                ImageDownloader.default.downloadImage(with: url) { (image, _, _, _) in
                    group.leave()
                    if let image = image {
                        images.append(image)
                    }
                }
            }
            group.notify(queue: DispatchQueue.main) {
                self.coverImageView.animationImages = images
                self.coverImageView.animationDuration = animationDuration
                self.coverImageView.startAnimating()
            }
        } else {
            coverImageView.kf.setImage(with: viewModel.imageURL)
        }
        avatarImageView.kf.setImage(with: viewModel.avatarImageURL)
        nameLabel.text = viewModel.name
        infoLabel.text = viewModel.info
        avatarCirCleImageView.image = viewModel.isRead ? #imageLiteral(resourceName: "StoryRead") : #imageLiteral(resourceName: "StoryUnread")

    }
    
    override var isSelected: Bool {
        set {}
        get { return super.isSelected }
    }
    
    override var isHighlighted: Bool {
        set {}
        get { return super.isHighlighted }
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
    
    private lazy var infoLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 10)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        coverMaskView.layer.cornerRadius = 10
        coverImageView.layer.cornerRadius = 10
        avatarImageView.layer.cornerRadius = 24
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.addSubview(coverMaskView)
        coverMaskView.fill(in: contentView)
        contentView.addSubview(coverImageView)
        coverImageView.fill(in: contentView)
        contentView.addSubview(infoLabel)
        infoLabel.centerX(to: contentView)
        infoLabel.align(.bottom, to: contentView, inset: 16)
        contentView.addSubview(nameLabel)
        nameLabel.centerX(to: contentView)
        nameLabel.pin(.top, to: infoLabel)
        contentView.addSubview(avatarCirCleImageView)
        avatarCirCleImageView.constrain(width: 50, height: 50)
        avatarCirCleImageView.centerX(to: contentView)
        avatarCirCleImageView.pin(.top, to: nameLabel)
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 48, height: 48)
        avatarImageView.center(to: avatarCirCleImageView)
    
    }

}
