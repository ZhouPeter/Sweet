//
//  BaseContentCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BaseContentCardCollectionViewCell: BaseCardCollectionViewCell {
    lazy var emojiView: EmojiControlView = {
        let view = EmojiControlView()
        view.backgroundColor = .clear
        return view
    } ()
    
    lazy var shareButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "CardShare"), for: .normal)
        button.addTarget(self, action: #selector(didPressShare(_:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .left
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        customContent.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left)
        emojiView.align(.bottom)
        emojiView.constrain(height: 50)
        customContent.addSubview(shareButton)
        shareButton.constrain(width: 50, height: 50)
        shareButton.align(.left, inset: 10)
        shareButton.centerY(to: emojiView)
    }
    
}
// MARK: - Actions
extension BaseContentCardCollectionViewCell {
    @objc private func didPressShare(_ sender: UIButton) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.shareCard(cardId: cardId!)
        }
    }
}

