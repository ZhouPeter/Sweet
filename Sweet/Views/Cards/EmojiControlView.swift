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
}
class EmojiControlView: UIView {
    weak var delegate: EmojiControlViewDelegate?
    private lazy var openButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Open"), for: .normal)
        button.addTarget(self, action: #selector(openAction(sender:)), for: .touchUpInside)
        return button
    }()
    private lazy var resultImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
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
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setup()
    }
    private var defaultEmojiList = [Int]()
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    func setup() {
        addSubview(resultImageView)
        avatarImageViews.forEach {
            $0.layer.cornerRadius = 16
            $0.clipsToBounds = true
            addSubview($0)
        }
        emojiImageViews.forEach { addSubview($0) }
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
    
    func updateResult(imageName: String, resultAvatarURLs: [URL]) {
        var insetX: CGFloat = 10
        let insetY: CGFloat = 9
        resultImageView.image = UIImage(named: imageName)
        resultImageView.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        resultImageView.isHidden = false
        insetX = insetX + emojiWidth + 20
        for (index, avatarURL) in resultAvatarURLs.enumerated() {
            avatarImageViews[index].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
            insetX += emojiWidth + emojiSpace
            avatarImageViews[index].isHidden = false
            avatarImageViews[index].kf.setImage(with: avatarURL)
        }
    }
    
    func updateShow(indexs: [Int]) {
        var insetX: CGFloat = 10
        let insetY: CGFloat = 9
        indexs.forEach {
            emojiImageViews[$0 - 1].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
            emojiImageViews[$0 - 1].isHidden = false
            insetX += emojiWidth + emojiSpace
            emojiImageViews[$0 - 1].image = UIImage(named: "Emoji\($0)")
            emojiImageViews[$0 - 1].tag = $0
        }
        openButton.frame = CGRect(x: insetX, y: 17, width: 16, height: 16)
        openButton.isHidden = false
    }
    
    func updateAllShow(indexs: [Int]) {
        updateShow(indexs: indexs)
        openButton.isHidden = true
        var insetX: CGFloat = 10 + CGFloat(defaultEmojiList.count) * 40
        let insetY: CGFloat = 9
        for (index, imageView) in emojiImageViews.enumerated() {
            logger.debug(imageView.tag)
            if !indexs.contains(imageView.tag) {
                imageView.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
                imageView.isHidden = false
                insetX += emojiWidth + emojiSpace
                imageView.image = UIImage(named: "Emoji\(index + 1)")
                imageView.tag = index + 1
            }
        }
    }
    
    private func clearUI() {
        for (index, imageView) in emojiImageViews.enumerated() {
            imageView.tag = index + 1
            imageView.isHidden = true
        }
        avatarImageViews.forEach { $0.isHidden = true }
        openButton.isHidden = true
        resultImageView.isHidden = true
    }
    
    @objc private func openAction(sender: UIButton) {
        delegate?.openEmojis()
        clearUI()
        updateAllShow(indexs: defaultEmojiList)
    }
    
    @objc private func selectEmojiAction(tap: UITapGestureRecognizer) {
        if let view = tap.view {
            delegate?.selectEmoji(emoji: view.tag)
        }
    }
}
