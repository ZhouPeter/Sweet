//
//  NewsCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SDWebImage
protocol ContentCardCollectionViewCellDelegate: NSObjectProtocol {
    func showImageBrowser(selectedIndex: Int)
    func contentCardComment(cardId: String, emoji: Int)
    func showProfile(userId: UInt64, setTop: SetTop?)
    func openEmojis(cardId: String)
    func shareCard(cardId: String)
}


class ContentCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = ContentCardViewModel
    var viewModel: ViewModelType?
    lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    } ()
    
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        return imageView
    } ()
    
    var imageViews = [UIImageView]()
    var imageViewContainers = [UIView]()
    var imageIcons = [UIButton]()
    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.backgroundColor = .clear
        view.delegate = self
        return view
    } ()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CardShare"), for: .normal)
        button.addTarget(self, action: #selector(didPressShare(_:)), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageViews.forEach( { $0.image = nil })
    }
    
    var contentLabelHeight: NSLayoutConstraint?
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 15)
        contentLabelHeight = contentLabel.constrain(height: contentLabel.font.lineHeight)
        customContent.addSubview(contentImageView)
        contentImageView.align(.left, to: customContent, inset: 5)
        contentImageView.align(.right, to: customContent, inset: 5)
        contentImageView.align(.bottom, to: customContent, inset: 50)
        contentImageView.pin(.bottom, to: contentLabel, spacing: 10)
        contentImageView.setViewRounded(cornerRadius: 5, corners: [.bottomLeft, .bottomRight])
        setupImageViews()
        customContent.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left)
        emojiView.pin(.bottom, to: contentImageView)
        emojiView.align(.bottom)
        customContent.addSubview(shareButton)
        shareButton.constrain(width: 24, height: 24)
        shareButton.align(.left, inset: 10)
        shareButton.centerY(to: emojiView)
        
    }
    
    private func setupImageViews() {
        for index in 0..<9 {
            let imageIcon = UIButton()
            imageIcon.layer.cornerRadius = 3
            imageIcon.layer.borderColor = UIColor.white.cgColor
            imageIcon.layer.borderWidth = 1
            imageIcon.clipsToBounds = true
            imageIcon.titleLabel?.font = UIFont.systemFont(ofSize: 12)
            imageIcon.titleLabel?.textColor = .white
            imageIcons.append(imageIcon)
            let imageView = UIImageView()
            imageView.backgroundColor = .clear
            imageView.contentMode = .scaleAspectFill
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressImage(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.backgroundColor = UIColor.black
            imageView.contentMode = .scaleAspectFill
            imageView.addSubview(imageIcon)
            imageIcon.align(.right, inset: 5)
            imageIcon.align(.bottom, inset: 5)
            imageIcon.constrain(width: 32, height: 16)
            imageViews.append(imageView)
            let container = UIView()
            container.backgroundColor = UIColor(hex: 0xf6f6f6)
            container.clipsToBounds = true
            container.layer.cornerRadius = 5
            container.layer.borderColor = UIColor(hex: 0xf2f2f2).cgColor
            container.layer.borderWidth = 0.5
            container.addSubview(imageView)
            imageView.fill(in: container)
            contentImageView.addSubview(container)
            imageViewContainers.append(container)
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentCardViewModel) {
        self.viewModel = viewModel
        self.cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.contentLabel.attributedText = viewModel.contentTextAttributed
                self.contentLabel.lineBreakMode = .byTruncatingTail
            }
        }
        update(with: viewModel.imageURLList)
        resetEmojiView()
    }
    
    func updateEmojiView(viewModel: ContentCardViewModel) {
        self.viewModel = viewModel
        resetEmojiView()
    }
    
    func resetEmojiView() {
        if let viewModel = viewModel {
            emojiView.update(indexs: viewModel.defaultEmojiList,
                             resultImage: viewModel.resultImageName,
                             resultAvatarURLs: viewModel.resultAvatarURLs,
                             emojiType: viewModel.emojiDisplayType)
        }
    }
    private func update(with imageURLs: [URL]?) {
        layout(urls: imageURLs)
    }
}

// MARK: - Actions
extension ContentCardCollectionViewCell {
    @objc private func didPressImage(_ tap: UITapGestureRecognizer) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate, let view = tap.view {
            delegate.showImageBrowser(selectedIndex: view.tag)
        }
    }
    
    @objc private func didPressShare(_ sender: UIButton) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.shareCard(cardId: cardId!)
        }
    }
}

extension ContentCardCollectionViewCell: EmojiControlViewDelegate {
    func didTapAvatar(index: Int) {
        if let delegate  = delegate as? ContentCardCollectionViewCellDelegate {
            if let viewModel = viewModel, let userIDs = viewModel.resultUseIDs {
                delegate.showProfile(userId: userIDs[index],
                                     setTop: SetTop(contentId: viewModel.contentId, preferenceId: nil))
            }
        }
    }
    
    func openEmojis() {
        if let delegate  = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.openEmojis(cardId: cardId!)
        }
    }
    
    func selectEmoji(emoji: Int) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.contentCardComment(cardId: cardId!, emoji: emoji)
        }
    }
}
