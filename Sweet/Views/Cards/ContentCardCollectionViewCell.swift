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
    func contentCardComment(cardId: String, emoji: Int)
    func showProfile(userId: UInt64)
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
    }()
    
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    var imageViews = [UIImageView]()
    private var imageMaskViews = [UIImageView]()

    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.isHidden = true
        view.layer.cornerRadius = (emojiHeight + 10) / 2
        view.delegate = self
        return view
    }()
    
    lazy var resultEmojiView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .clear
        imageView.isHidden = true
        return imageView
    }()
    
    lazy var resultCommentLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 12
        label.layer.masksToBounds = true
        label.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private var avatarImageViews: [UIImageView] = [UIImageView(), UIImageView(), UIImageView()]
    private var avatarImageContraints: [NSLayoutConstraint] =  [NSLayoutConstraint]()
    private var emojiViewWidthConstrain: NSLayoutConstraint?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    func hiddenEmojiView(isHidden: Bool) {
        if isHidden {
            emojiView.isHidden = isHidden
        } else {
            if !resultEmojiView.isHidden || !resultCommentLabel.isHidden {
                return
            }
            emojiView.isHidden = isHidden
        }
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
        customContent.addSubview(resultEmojiView)
        resultEmojiView.constrain(width: 120, height: 120)
        resultEmojiView.align(.bottom, inset: 94)
        resultEmojiView.centerX(to: customContent)
        customContent.addSubview(resultCommentLabel)
        resultCommentLabel.constrain(width: 200, height: 104)
        resultCommentLabel.centerX(to: customContent)
        resultCommentLabel.align(.top, inset: 200)
        addAvatarImageViews()
    }
    
    private func setImageViews() {
        var orginX: CGFloat = 0
        var orginY: CGFloat = 0
        let sumWidth: CGFloat = UIScreen.mainWidth() - 20
        let sumHeight: CGFloat = sumWidth * 10 / 9
        for index in 0..<9 {
            let imageView = UIImageView()
            imageView.contentMode = .scaleAspectFill
            imageView.clipsToBounds = true
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
            let maskView = UIImageView(image: UIImage.bubbleImage(named: "CardMask", orientation: .up))
            imageView.addSubview(maskView)
            imageMaskViews.append(maskView)
        }
    }
    
    private func addAvatarImageViews() {
        var centerXSpacing: CGFloat = 50
        var index = 0
        avatarImageViews.forEach { (imageView) in
            imageView.tag = index
            index += 1
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(didPressResultAvatar(_:)))
            imageView.addGestureRecognizer(tap)
            imageView.isHidden = true
            imageView.contentMode = .scaleAspectFill
            customContent.addSubview(imageView)
            imageView.constrain(width: 40, height: 40)
            imageView.align(.bottom, inset: 40)
            let contraint = imageView.centerX(to: customContent, offset: -centerXSpacing)
            avatarImageContraints.append(contraint!)
            imageView.setViewRounded()
        }
        centerXSpacing -= 50
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentCardViewModel) {
        self.viewModel = viewModel
        self.cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.text = viewModel.contentString
        setContentImages(images: viewModel.contentImages)
     
        if let resultImageName = viewModel.resultImageName, let urls = viewModel.resultAvatarURLs {
            hiddenEmojiView(isHidden: true)
            resultEmojiView.isHidden = false
            resultCommentLabel.isHidden = true
            resultEmojiView.image = UIImage(named: "\(resultImageName)")
            let sumButtonWidth: CGFloat = CGFloat(urls.count * 40 + (urls.count - 1) * 10)
            avatarImageViews.forEach({ $0.isHidden = true })
            for (offset, url) in urls.enumerated() {
                avatarImageViews[offset].isHidden = false
                avatarImageViews[offset].kf.setImage(with: url)
                let offsetCenterX: CGFloat = 40.0 / 2 + CGFloat(offset) * 50  - sumButtonWidth / 2
                avatarImageContraints[offset].constant = offsetCenterX
            }
        } else if let resultComment = viewModel.resultComment {
            hiddenEmojiView(isHidden: true)
            resultEmojiView.isHidden = true
            resultCommentLabel.isHidden = false
            resultCommentLabel.text = resultComment
            avatarImageViews.forEach({ $0.isHidden = true })
        } else {
            hiddenEmojiView(isHidden: true)
            resultCommentLabel.isHidden = true
            resultEmojiView.isHidden = true
            avatarImageViews.forEach({ $0.isHidden = true })
        }
        emojiView.updateDefault(names: viewModel.defaultImageNameList)
    }
    
    private func setContentImages(images: [ContentImageModel]?) {
        guard let images = images else {
            imageViews.forEach { $0.isHidden = true }
            return
        }
        let padding: CGFloat = 2
        var orginX: CGFloat = padding
        var orginY: CGFloat = padding
        let boxWidth: CGFloat = contentImageView.bounds.width - padding * 2
        let scale = boxWidth / 27
        for (offset, imageView) in imageViews.enumerated() {
            let maskView = imageMaskViews[offset]
            maskView.isHidden = true
            if offset < images.count {
                imageView.isHidden = false
                contentImageView.addSubview(imageView)
                let current = images[offset]
                let imageSize =
                    CGSize(width: floor(current.size.width * scale), height: floor(current.size.height * scale))
                if orginX + imageSize.width > boxWidth + padding {
                    orginX = padding
                    orginY += floor(images[offset - 1].size.height * scale)
                }
                imageView.frame = CGRect(origin: CGPoint(x: orginX, y: orginY), size: imageSize)
                maskView.frame = imageView.bounds
                imageView.kf.setImage(with: images[offset].imageURL.middleCutting(size: imageSize)) { (image, _, _, _) in
                    guard image != nil else { return }
                    maskView.isHidden = false
                }
                orginX += imageSize.width
            } else {
                imageView.isHidden = true
                imageView.removeFromSuperview()
            }
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
            delegate.showProfile(userId: viewModel!.resultUseIDs![view.tag])
        }
    }
}

extension ContentCardCollectionViewCell: EmojiControlViewDelegate {

    func openKeyboard() {
        if let delegate  = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.openKeyword()
        }
    }
    
    func openEmojis() {
        UIView.animate(withDuration: 0.3) {
            self.emojiViewWidthConstrain?.constant = UIScreen.mainWidth() - 40
            self.emojiView.openEmojis()
        }
    }
    func selectEmoji(emoji: Int) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.contentCardComment(cardId: cardId!, emoji: emoji)
        }
    }
}
