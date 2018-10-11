//
//  BaseContentCardCollectionViewCell.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class BaseContentCardCollectionViewCell: BaseCardCollectionViewCell {
    var groupId: UInt64?
    var contentId: String?
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
    
    lazy var joinGroupButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 18)
        button.contentHorizontalAlignment = .center
        button.addTarget(self, action: #selector(didPressAddGroup(_:)), for: .touchUpInside)
        return button
    }()
    
    lazy var groupBackgroudImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "GroupBg"))
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        menuButton.isHidden = false
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        contentId = nil
        groupId = nil
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        contentView.insertSubview(groupBackgroudImageView, belowSubview: customContent)
        groupBackgroudImageView.fill(in: customContent)
        customContent.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left)
        emojiView.align(.bottom)
        emojiView.constrain(height: 50)
        customContent.addSubview(shareButton)
        shareButton.constrain(width: 50, height: 50)
        shareButton.align(.left, inset: 10)
        shareButton.centerY(to: emojiView)
        customContent.addSubview(joinGroupButton)
        joinGroupButton.constrain(height: 50)
        joinGroupButton.centerY(to: shareButton)
        joinGroupButton.align(.left, inset: 15)
        joinGroupButton.align(.right, inset: 15)
    }
    
    func update(isGroupChat: Bool, contentId: String?, groupId: UInt64?, joinGroupButtonString: String?) {
        if isGroupChat {
            self.contentId = contentId
            self.groupId = groupId
            emojiView.isHidden = true
            joinGroupButton.isHidden = false
            joinGroupButton.setTitle(joinGroupButtonString, for: .normal)
            groupBackgroudImageView.isHidden = false
            customContent.isShadowEnabled = false
            shareButton.setImage(#imageLiteral(resourceName: "CardShare"), for: .normal)
            shareButton.isHidden = true
        } else {
            emojiView.isHidden = false
            joinGroupButton.isHidden = true
            groupBackgroudImageView.isHidden = true
            customContent.isShadowEnabled = true
            shareButton.setImage(#imageLiteral(resourceName: "CardShareGray"), for: .normal)
            shareButton.isHidden = false
        }
        
    }
    
    func updateButtonString(joinGroupButtonString: String?){
        joinGroupButton.setTitle(joinGroupButtonString, for: .normal)
    }
    
}
// MARK: - Actions
extension BaseContentCardCollectionViewCell {
    @objc private func didPressShare(_ sender: UIButton) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate {
            delegate.shareCard(cardId: cardId!)
        }
    }
    
    @objc private func didPressAddGroup(_ sender: UIButton) {
        if let delegate = delegate as? ContentCardCollectionViewCellDelegate,
            let groupId = groupId,
            let contentId = contentId {
            delegate.joinGroup(groupId: groupId, cardId: cardId!, contentId: contentId)
        }
        
    }
}

