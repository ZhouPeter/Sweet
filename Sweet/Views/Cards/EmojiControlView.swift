//
//  EmojiControlView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

let emojiSpace: CGFloat = 8
let emojiWidth: CGFloat = 32
let emojiHeight: CGFloat = emojiWidth
protocol EmojiControlViewDelegate: NSObjectProtocol {
    func openEmojis()
    func selectEmoji(emoji: Int)
    func didTapAvatar(index: Int)
}

class EmojiControlView: UIView {
    weak var delegate: EmojiControlViewDelegate?
    private lazy var openButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Open"), for: .normal)
        button.addTarget(self, action: #selector(openAction(sender:)), for: .touchUpInside)
        button.contentHorizontalAlignment = .right
        return button
    }()
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()
    private lazy var segmentView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        return view
    }()
    private lazy var emojiImageViews: [UIImageView] = {
        var imageViews = [UIImageView]()
        for index in 1...6 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Emoji\(index)")
            imageView.tag = index
            imageView.isUserInteractionEnabled = true
            let tap = UITapGestureRecognizer(target: self, action: #selector(selectEmojiAction(tap:)))
            imageView.addGestureRecognizer(tap)
            imageViews.append(imageView)
        }
        return imageViews
    }()
    
    private lazy var avatarImageViews: [UIImageView] = {
        return [UIImageView(), UIImageView(), UIImageView()]
    }()
    private var defaultEmojiList = [Int]()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        let tap = UITapGestureRecognizer(target: self, action: nil)
        addGestureRecognizer(tap)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        addSubview(resultImageView)
        addSubview(segmentView)
        var index = 0
        avatarImageViews.forEach {
            $0.isUserInteractionEnabled = true
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            $0.tag = index
            let tap = UITapGestureRecognizer(target: self, action: #selector(didTapAvatar(_:)))
            $0.addGestureRecognizer(tap)
            index += 1
            addSubview($0)
        }
        emojiImageViews.forEach {
            layoutIfNeeded()
            $0.frame = CGRect(x: bounds.width - 10 - 32, y: 9, width: 32, height: 32)
            addSubview($0)
        }
        addSubview(openButton)
    }
    
    func update(indexs: [Int], resultImage: String?, resultAvatarURLs: [URL]?, emojiType: EmojiViewDisplay) {
        clearUI()
        self.defaultEmojiList = indexs
        if let image = resultImage, let avatarURLs = resultAvatarURLs {
            updateResult(imageName: image, resultAvatarURLs: avatarURLs)
        } else if emojiType == .show {
            updateShow(indexs: indexs)
        } else if emojiType == .allShow {
            updateAllShow(indexs: indexs)
        }
    }
    
    private func updateResult(imageName: String, resultAvatarURLs: [URL]) {
        layoutIfNeeded()
        var insetX: CGFloat = bounds.width - 10 - 32
        let insetY: CGFloat = 9
        let lineWidth: CGFloat = 1
        resultImageView.image = UIImage(named: imageName)
        resultImageView.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        resultImageView.isHidden = false
        insetX -= lineWidth + emojiSpace
        if resultAvatarURLs.count > 0 {
            segmentView.frame = CGRect(x: insetX, y: insetY, width: 1, height: emojiHeight)
            segmentView.isHidden = false
            insetX -= emojiWidth + emojiSpace
        }
        for (index, avatarURL) in resultAvatarURLs.enumerated() {
            avatarImageViews[index].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
            insetX -= emojiWidth + emojiSpace
            avatarImageViews[index].isHidden = false
            avatarImageViews[index].kf.setImage(with: avatarURL)
        }
    }
    
    private func updateShow(indexs: [Int]) {
        layoutIfNeeded()
        var insetX: CGFloat = bounds.width - 10 - 32
        let insetY: CGFloat = 9
        indexs.forEach {
            emojiImageViews[$0 - 1].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
            emojiImageViews[$0 - 1].isHidden = false
            insetX -= emojiWidth + emojiSpace
            emojiImageViews[$0 - 1].image = UIImage(named: "Emoji\($0)")
            emojiImageViews[$0 - 1].tag = $0
        }
        openButton.frame = CGRect(x: insetX - emojiSpace, y: 17, width: 40, height: 16)
        openButton.isHidden = false
    }
    
    private func updateAllShow(indexs: [Int]) {
        updateShow(indexs: indexs)
        openButton.isHidden = true
        layoutIfNeeded()
        var insetX: CGFloat = bounds.width - 10 - 32 - CGFloat(defaultEmojiList.count) * 40
        let insetY: CGFloat = 9
        for (index, imageView) in emojiImageViews.enumerated() {
            logger.debug(imageView.tag)
            if !indexs.contains(imageView.tag) {
                imageView.transform = .identity
                UIView.animate(withDuration: 0.2) {
                    let transform = CGAffineTransform(translationX: insetX - imageView.frame.origin.x, y: 0)
                    imageView.transform = transform
                }
                imageView.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
                imageView.isHidden = false
                insetX -= emojiWidth + emojiSpace
                imageView.image = UIImage(named: "Emoji\(index + 1)")
                imageView.tag = index + 1
            }
        }
    }
    
    private func clearUI() {
        for (index, imageView) in emojiImageViews.enumerated() {
            imageView.tag = index + 1
            layoutIfNeeded()
            imageView.frame = CGRect(x: bounds.width - 10 - 32, y: 9, width: 32, height: 32)
            imageView.isHidden = true
            imageView.isUserInteractionEnabled = true
        }
        avatarImageViews.forEach { $0.isHidden = true }
        openButton.isHidden = true
        resultImageView.isHidden = true
        segmentView.isHidden = true
    }
}
// MARK: - Action Methods
extension EmojiControlView {
    @objc private func didTapAvatar(_ tap: UITapGestureRecognizer) {
        delegate?.didTapAvatar(index: tap.view!.tag)
    }
    @objc private func openAction(sender: UIButton) {
        delegate?.openEmojis()
        clearUI()
        updateAllShow(indexs: defaultEmojiList)
    }
    
    @objc private func selectEmojiAction(tap: UITapGestureRecognizer) {
        if let view = tap.view {
            emojiImageViews.forEach { $0.isUserInteractionEnabled = false }
            delegate?.selectEmoji(emoji: view.tag)
        }
    }
}
