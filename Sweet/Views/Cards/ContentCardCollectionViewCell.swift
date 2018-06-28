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
}


class ContentCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = ContentCardViewModel
    private var viewModel: ViewModelType?
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 3
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

    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.delegate = self
        return view
    } ()
    
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
    
    private func setupUI() {
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, to: customContent, inset: 10)
        contentLabel.align(.right, to: customContent, inset: 10)
        contentLabel.pin(.bottom, to: titleLabel, spacing: 15)
        customContent.addSubview(contentImageView)
        contentImageView.align(.left, to: customContent, inset: 5)
        contentImageView.align(.right, to: customContent, inset: 5)
        contentImageView.align(.bottom, to: customContent, inset: 50)
        contentImageView.heightAnchor.constraint(
                equalTo: contentImageView.widthAnchor,
                multiplier: 1).isActive = true
        contentImageView.setViewRounded(cornerRadius: 5, corners: [.bottomLeft, .bottomRight])
        setupImageViews()
        
        customContent.addSubview(emojiView)
        emojiView.align(.left)
        emojiView.align(.right, inset: 50)
        emojiView.pin(.bottom, to: contentImageView)
        emojiView.align(.bottom)

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
        update(with: viewModel.contentImages)
        resetEmojiView()
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
                let scale = UIScreen.main.scale
                let imageSize =
                    CGSize(width: imageView.bounds.size.width * scale, height: imageView.bounds.height * scale)
                imageView.kf.setImage(
                    with: URL(string: image.url)?.middleCutting(size: imageSize),
                    completionHandler: { (image, _, _, _) in
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
    
    @objc private func didPressResultAvatar(_ tap: UITapGestureRecognizer) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate, let view = tap.view {
            delegate.showProfile(userId: viewModel!.resultUseIDs![view.tag],
                                 setTop: SetTop(contentId: viewModel?.contentId, preferenceId: nil))
        }
    }
}

extension ContentCardCollectionViewCell: EmojiControlViewDelegate {
    
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
