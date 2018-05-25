//
//  NewsCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ContentCardCollectionViewCellDelegate: NSObjectProtocol {
    func showImageBrowser(selectedIndex: Int)
    func openKeyword()
}
class ContentCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    
    typealias ViewModelType = ContentCardViewModel
    private var viewModel: ViewModelType?
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
    
    var imageViews = [UIImageView]()
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.isHidden = true
        view.layer.cornerRadius = (emojiHeight + 10) / 2
        view.delegate = self
        return view
    }()
    private var emojiViewWidthConstrain: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func resetEmojiView() {
        emojiView.isHidden = true
        emojiViewWidthConstrain?.constant = emojiWidth * 2 + 10 + 10 + 25 + 5
        if let viewModel = viewModel {
            emojiView.reset(names: viewModel.defaultImageNameList)
        }
    }
    
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 15)
        customContent.addSubview(contentImageView)
        contentImageView.align(.left, to: customContent)
        contentImageView.align(.right, to: customContent)
        contentImageView.align(.bottom, to: customContent)
        contentImageView.equal(.height, to: contentImageView)
        contentImageView.heightAnchor.constraint(
                equalTo: contentImageView.widthAnchor,
                multiplier: 10.0 / 9.0).isActive = true
        contentImageView.setViewRounded(cornerRadius: 10, corners: [.bottomLeft, .bottomRight])
        setImageViews()
        customContent.addSubview(emojiView)
    
        emojiViewWidthConstrain = emojiView.constrain(width: emojiWidth * 2 + 10 + 10 + 25 + 5)
        emojiView.constrain(height: emojiHeight + 10)
        emojiView.align(.bottom, to: customContent, inset: 10)
        emojiView.centerX(to: customContent)

    }
    
    private func setImageViews() {
        var orginX: CGFloat = 0
        var orginY: CGFloat = 0
        let sumWidth: CGFloat = UIScreen.mainWidth() - 20
        let sumHeight: CGFloat = sumWidth * 10 / 9
        for index in 0..<9 {
            let imageView = UIImageView()
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressImage(_:)))
            imageView.addGestureRecognizer(tap)
            if orginX + sumWidth / 3 > sumWidth {
                orginX = 0
                orginY += sumHeight / 3
            }
            let rect = CGRect(origin: CGPoint(x: orginX, y: orginY),
                              size: CGSize(width: sumWidth / 3, height: sumHeight / 3))
            imageView.frame = rect
            orginX += sumWidth / 3
            imageView.backgroundColor = UIColor.black
            imageView.contentMode = .scaleAspectFill
            imageViews.append(imageView)
            contentImageView.addSubview(imageView)

        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentCardViewModel) {
        self.viewModel = viewModel
        contentLabel.text = viewModel.contentString
        setContentImages(images: viewModel.contentImages)
        emojiView.updateDefault(names: viewModel.defaultImageNameList)
    }
    
    @objc private func didPressImage(_ tap: UITapGestureRecognizer) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate, let view = tap.view {
            delegate.showImageBrowser(selectedIndex: view.tag)
        }
    }
    
    private func setContentImages(images: [ContentImageModel]?) {
        guard let images = images else {
            imageViews.forEach { $0.isHidden = true }
            return
        }
        var orginX: CGFloat = 0
        var orginY: CGFloat = 0
        let sumWidth: CGFloat = UIScreen.mainWidth() - 20
        for (offset, imageView) in imageViews.enumerated() {
            if offset < images.count {
                imageView.isHidden = false
                contentImageView.addSubview(imageView)
                let imageSize = images[offset].size
                if orginX + imageSize.width > sumWidth {
                    orginX = 0
                    orginY += images[offset - 1].size.height
                }
                let rect = CGRect(origin: CGPoint(x: orginX, y: orginY),
                                  size: CGSize(width: imageSize.width, height: imageSize.height))
                imageView.frame = rect
                imageView.kf.setImage(with: images[offset].imageURL)
                orginX += imageSize.width
            } else {
                imageView.isHidden = true
                imageView.removeFromSuperview()
            }
        }
    }
}

extension ContentCardCollectionViewCell: EmojiControlViewDelegate {
    func openKeyword() {
        if let delegate  = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.openKeyword()
        }
    }
    
    func openEmojis() {
        emojiViewWidthConstrain?.constant = UIScreen.mainWidth() - 40
        emojiView.openEmojis()
    }
}
