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
        imageView.image = nil
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
        recoveryLabel.pin(to: recoveryImageView, edge: .right)
    
    }

    private func setAnimationImages(url: URL) {
        let animationDuration: TimeInterval = 0.5
        let count = 3
        var urls = [URL]()
        let urlString = url.absoluteString
        for index in 0 ..< count {
            let time = 0.5 / Double(count) * Double(index + 1)
            let width = Int(UIScreen.mainWidth() / 3)
            let height = Int(UIScreen.mainHeight() / 3)
            let urlString = urlString
                + "?vframe/jpg/offset/\(time)/w/\(width)/h/\(height)"
            let url = URL(string: urlString)!
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
            self.storyImageView.animationImages = images
            self.storyImageView.animationDuration = animationDuration
            self.storyImageView.startAnimating()
        }
    }
    
    func update(viewModel: StoryCellViewModel) {
        storyImageView.image = nil
        storyImageView.animationImages = nil
        storyImageView.stopAnimating()
        if let videoURL = viewModel.videoURL {
            setAnimationImages(url: videoURL)
        } else if let imageURL = viewModel.imageURL {
            storyImageView.kf.setImage(with: imageURL)
        }
    }
}
