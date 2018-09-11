//
//  LongTextCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import YYText
class SourceTitleView: UIView {
    private lazy var sourceImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private lazy var backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        return view
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var sourceLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor(white: 0, alpha: 0.5)
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        addSubview(backgroundView)
        backgroundView.fill(in: self)
        addSubview(titleLabel)
        titleLabel.align(.left, inset: 8)
        titleLabel.align(.right, inset: 8)
        titleLabel.align(.top, inset: 8)
        addSubview(sourceLabel)
        sourceLabel.align(.left, to: titleLabel)
        sourceLabel.pin(.bottom, to: titleLabel)
        addSubview(sourceImageView)
        sourceImageView.align(.left)
        sourceImageView.align(.bottom)
        sourceImageView.align(.right)
        sourceImageView.heightAnchor.constraint(equalTo: sourceImageView.widthAnchor, multiplier: 0.4).isActive = true
        
    }
    
    func update(thumbnailURL: URL?, title: NSAttributedString?, sourceText: String?) {
        titleLabel.attributedText = title
        sourceLabel.text = sourceText
        sourceImageView.sd_setImage(with: thumbnailURL)
    }
}

class LongTextCardCollectionViewCell: BaseContentCardCollectionViewCell, CellReusable, CellUpdatable {
    
    typealias ViewModelType = LongTextCardViewModel
    private var viewModel: ViewModelType?
    private lazy var sourceTitleView: SourceTitleView = {
        let view = SourceTitleView(frame: .zero)
        view.layer.cornerRadius = 5
        view.clipsToBounds = true
        return view
    }()
    private lazy var contentLabel: YYLabel = {
        let label = YYLabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        emojiView.delegate = self
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var sourceHeightConstraint: NSLayoutConstraint?
    private func setupUI() {
        customContent.addSubview(sourceTitleView)
        sourceTitleView.pin(.bottom, to: titleLabel, spacing: 15)
        sourceTitleView.align(.left, inset: 10)
        sourceTitleView.align(.right, inset: 10)
        sourceHeightConstraint = sourceTitleView.constrain(height: 220)
        customContent.addSubview(contentLabel)
        contentLabel.align(.left, inset: 10)
        contentLabel.align(.right, inset: 10)
        contentLabel.pin(.bottom, to: sourceTitleView, spacing: 5)
        contentLabel.align(.bottom, inset: 50)
        
    }
    
    func updateWith(_ viewModel: LongTextCardViewModel) {
        self.viewModel = viewModel
        self.cardId = viewModel.cardId
        titleLabel.text = viewModel.titleString
        sourceHeightConstraint?.constant = viewModel.sourceHeight
        sourceTitleView.update(thumbnailURL: viewModel.thumbnailURL,
                               title: viewModel.sourceTextAttributed,
                               sourceText: viewModel.sourceText)
        DispatchQueue.global().async {
            DispatchQueue.main.async {
                let allLabel = YYLabel()
                let text = NSMutableAttributedString(string: "... [全文]")
                text.yy_font = self.contentLabel.font
                allLabel.attributedText = text
                allLabel.sizeToFit()
                allLabel.font = self.contentLabel.font
                let truncationToken = NSMutableAttributedString.yy_attachmentString(
                    withContent: allLabel,
                    contentMode: .center,
                    attachmentSize: allLabel.frame.size,
                    alignTo: text.yy_font!,
                    alignment: .center)
                self.contentLabel.attributedText = viewModel.contentTextAttributed
                self.contentLabel.truncationToken = truncationToken
                self.contentLabel.lineBreakMode = .byTruncatingTail
            }
        }
        resetEmojiView()
        
    }
    func updateEmojiView(viewModel: LongTextCardViewModel) {
        self.viewModel = viewModel
        resetEmojiView()
    }
    
    func resetEmojiView() {
        if let viewModel = viewModel {
            emojiView.update(indexs: [1, 2, 6],
                             resultImage: viewModel.resultImageName,
                             resultAvatarURLs: viewModel.resultAvatarURLs,
                             emojiType: viewModel.emojiDisplayType)
        }
    }
  
    
}


extension LongTextCardCollectionViewCell: EmojiControlViewDelegate {
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
