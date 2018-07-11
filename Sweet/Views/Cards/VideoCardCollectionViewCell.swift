//
//  VideoCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation

class VideoCardCollectionViewCell: BaseCardCollectionViewCell, CellReusable, CellUpdatable {
    typealias ViewModelType = ContentVideoCardViewModel
    private var viewModel: ViewModelType?
    private lazy var contentLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = .black
        label.numberOfLines = 0
        return label
    }()
    
    var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
        
    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.backgroundColor = .clear
        view.delegate = self
        return view
    }()
    
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
    private var contentViewHeight: NSLayoutConstraint?
    private var contentLabelHeight: NSLayoutConstraint?
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
        contentViewHeight = contentImageView.constrain(height: UIScreen.mainWidth() - 30)
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func updateWith(_ viewModel: ContentVideoCardViewModel) {
        self.viewModel = viewModel
        self.cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        contentLabel.attributedText = viewModel.contentTextAttributed
        contentLabel.lineBreakMode = .byTruncatingTail
        contentImageView.kf.setImage(with:  viewModel.videoURL.videoThumbnail())
        resetEmojiView()
        loadItemValues()

    }
    
    func updateEmojiView(viewModel: ContentVideoCardViewModel) {
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
    
    private func loadItemValues() {
        let resource = SweetPlayerResource(url: viewModel!.videoURL)
        let asset = resource.definitions[0].avURLAsset
        asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
            DispatchQueue.main.async {
                if asset.isPlayable {
                    self.loadedResourceForPlay(asset: asset)
                }
            }
        }
    }
    
    private func loadedResourceForPlay(asset: AVAsset) {
        let tracks = asset.tracks
        let videoWidth = contentImageView.bounds.width
        for track in tracks where track.mediaType  == .video {
            let naturalSize = track.naturalSize
            let videoMaxHeight = cardCellHeight - 110 - titleLabel.font.lineHeight - contentLabel.font.lineHeight
            if naturalSize.width < naturalSize.height {
                if videoMaxHeight / videoWidth > naturalSize.height / naturalSize.width {
                    let scaleHeight = videoWidth * (naturalSize.height / naturalSize.width)
                    contentViewHeight?.constant = scaleHeight
                    contentLabelHeight?.constant = contentLabel.font.lineHeight + videoMaxHeight - scaleHeight
                } else {
                    contentViewHeight?.constant = videoMaxHeight
                    contentLabelHeight?.constant = contentLabel.font.lineHeight
                }
                for subview in contentImageView.subviews {
                    if let subview = subview as? SweetPlayerView {
                        customContent.layoutIfNeeded()
                        subview.frame = contentImageView.bounds
                    }
                }
            } else {
                let videoHeight = videoWidth
                let contentMaxHeight = cardCellHeight - 110 - titleLabel.font.lineHeight - videoHeight
                let contentHeight = viewModel!.contentHeight
                contentLabelHeight?.constant = contentHeight > contentMaxHeight ? contentMaxHeight : contentHeight
                contentViewHeight?.constant = videoHeight
            }
        }
    }

}
// MARK: - Actions
extension VideoCardCollectionViewCell {
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
extension VideoCardCollectionViewCell: EmojiControlViewDelegate {
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
