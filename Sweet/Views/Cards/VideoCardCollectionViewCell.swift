//
//  VideoCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import AVFoundation
protocol VideoCardCollectionViewCellDelegate: NSObjectProtocol {
    func showVideoPlayerController(playerView: SweetPlayerView, cardId: String)
}
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
    
    lazy var contentImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .black
        imageView.tag = 10086
        imageView.isUserInteractionEnabled = true
        imageView.layer.cornerRadius = 5
        imageView.clipsToBounds = true
        return imageView
    }()
    
    lazy var playerView: SweetPlayerView = {
        let controlView = SweetPlayerCellControlView()
        let view = SweetPlayerView(controlView: controlView)
        view.panGesture.isEnabled = false
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressVideo(_:)))
        controlView.addGestureRecognizer(tap)
        view.backgroundColor = .black
        view.isUserInteractionEnabled = true
        return view
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
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentImageView.image = nil
        playerView.playerLayer?.resetPlayer()
        playerView.controlView.hideLoader()
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
        customContent.addSubview(playerView)
        playerView.fill(in: contentImageView)
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
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                self.contentLabel.attributedText = viewModel.contentTextAttributed
                self.contentLabel.lineBreakMode = .byTruncatingTail
            }
        }
        contentImageView.sd_setImage(with: viewModel.videoPicURL ?? viewModel.videoURL.videoThumbnail())
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
        
        if let asset = playerView.avPlayer?.currentItem?.asset, asset.isPlayable,
            let urlAsset = asset as? AVURLAsset,
            urlAsset.url == viewModel!.videoURL {
            loadedResourceForPlay(asset: asset)
        } else {
            let resource = SweetPlayerResource(url: viewModel!.videoURL)
            let asset = resource.definitions[0].avURLNoCacheAsset
            asset.loadValuesAsynchronously(forKeys: ["tracks"]) {
                DispatchQueue.main.async {
                    if asset.isPlayable {
                        self.loadedResourceForPlay(asset: asset)
                    }
                }
            }
        }
    }
    
    private func loadedResourceForPlay(asset: AVAsset) {
        guard  let viewModel = viewModel else { return }
        guard let track = asset.tracks(withMediaType: .video).first else { return }
        let videoWidth = contentImageView.bounds.width
        let contentHeight = viewModel.contentHeight
        let videoContentSumHeight = cardCellHeight - 110 - titleLabel.font.lineHeight
        let contentMaxHeight = videoContentSumHeight - videoWidth
        let naturalSize = track.naturalSize
        logger.debug(viewModel.contentTextAttributed ?? "") 
        logger.debug(naturalSize)
        if naturalSize.width < naturalSize.height {
            var videoHeight = videoContentSumHeight - min(contentHeight, contentMaxHeight)
            if contentLabel.text == "" || contentLabel.text == nil {
                videoHeight += 10 + contentHeight
            }
            if videoHeight > videoWidth {
                if videoHeight / videoWidth > naturalSize.height / naturalSize.width {
                    videoHeight = videoWidth * (naturalSize.height / naturalSize.width)
                }
            } else {
                videoHeight = videoWidth
            }
            contentViewHeight?.constant = videoHeight
            contentLabelHeight?.constant =  min(contentHeight, contentMaxHeight)
        } else {
            contentLabelHeight?.constant =  min(contentHeight, contentMaxHeight)
            contentViewHeight?.constant = videoContentSumHeight - min(contentHeight, contentMaxHeight)
        }
        for subview in contentImageView.subviews {
            if let subview = subview as? SweetPlayerView {
                customContent.layoutIfNeeded()
                subview.frame = contentImageView.bounds
            }
        }
    }
}
// MARK: - Actions
extension VideoCardCollectionViewCell {

    @objc private func didPressShare(_ sender: UIButton) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.shareCard(cardId: cardId!)
        }
    }
    
    @objc private func didPressVideo(_ tap: UITapGestureRecognizer) {
        if let delegate = delegate as? VideoCardCollectionViewCellDelegate {
            delegate.showVideoPlayerController(playerView: playerView, cardId: viewModel!.cardId)
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
