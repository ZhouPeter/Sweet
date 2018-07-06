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
    
//    lazy var contentWebView: UIWebView = {
//        let webView = UIWebView()
//        return webView
//    }()
    
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        return imageView
    } ()
    
    var imageViews = [UIImageView]()
    var imageViewContainers = [UIView]()

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
    
    func resetEmojiView() {
        if let viewModel = viewModel {
            emojiView.update(indexs: viewModel.defaultEmojiList,
                             resultImage: viewModel.resultImageName,
                             resultAvatarURLs: viewModel.resultAvatarURLs,
                             emojiType: viewModel.emojiDisplayType)
        }
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
//        contentImageView.heightAnchor.constraint(
//                equalTo: contentImageView.widthAnchor,
//                multiplier: 1).isActive = true
        contentImageView.pin(.bottom, to: contentLabel, spacing: 10)
        contentImageView.setViewRounded(cornerRadius: 5, corners: [.bottomLeft, .bottomRight])
        setupImageViews()
        
        customContent.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left, inset: 50)
        emojiView.pin(.bottom, to: contentImageView)
        emojiView.align(.bottom)
        customContent.addSubview(shareButton)
        shareButton.constrain(width: 24, height: 24)
        shareButton.align(.left, inset: 10)
        shareButton.centerY(to: emojiView)

    }
    
    private func setupImageViews() {
        for index in 0..<9 {
            let imageView = UIImageView()
            imageView.backgroundColor = .clear
            imageView.contentMode = .scaleAspectFill
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressImage(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.backgroundColor = UIColor.black
            imageView.contentMode = .scaleAspectFill
            imageViews.append(imageView)
            let container = UIView()
            container.backgroundColor = UIColor(hex: 0xf6f6f6)
            container.clipsToBounds = true
            container.layer.cornerRadius = 5
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
        contentLabel.attributedText = viewModel.contentTextAttributed
        contentLabel.lineBreakMode = .byTruncatingTail
        update(with: viewModel.imageURLList)
        resetEmojiView()
    }
    
    private func update(with imageURLs: [URL]?) {
        layout(urls: imageURLs)
    }
    
    private func update(with images: [[ContentImage]]?) {
        imageViews.forEach { view in
            view.alpha = 0
            view.kf.cancelDownloadTask()
        }
        imageViewContainers.forEach { view in
            view.isHidden = true
        }
        guard let rowImages = images, rowImages.isNotEmpty else { return }
        let margin: CGFloat = 0
        let spacing: CGFloat = 3
        let width = contentImageView.bounds.width - margin * 2
        let height = contentImageView.bounds.height - margin * 2
        let rows = CGFloat(rowImages.count)
        let factorH = (height - spacing * (rows - 1)) / rowImages.reduce(CGFloat(0), { $0 + ($1.first?.height ?? 0) })
        var viewIndex = 0
        var x = margin
        var y = margin
        rowImages.forEach { (columnImages) in
            let columns = CGFloat(columnImages.count)
            let factorW = (width - spacing * (columns - 1)) / columnImages.reduce(CGFloat(0), { $0 + $1.width })
            var rowHeight: CGFloat = 0
            columnImages.forEach { image in
                let imageView = imageViews[viewIndex]
                let container = imageViewContainers[viewIndex]
                container.isHidden = false
                container.frame = CGRect(x: x, y: y, width: image.width * factorW, height: image.height * factorH)
                let url = URL(string: image.url)?.imageView2(size: imageView.bounds.size)
                imageView.kf.setImage(with: url, completionHandler: { (image, _, _, _) in
                    guard image != nil else { return }
                    UIView.animate(withDuration: 0.25, animations: {
                        imageView.alpha = 1
                    })
                })
                viewIndex += 1
                x += container.bounds.width + spacing
                rowHeight = container.bounds.height
            }
            x = margin
            y += rowHeight + spacing
        }
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
