//
//  EmojiControlView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

let emojiSpace: CGFloat = 10
let emojiWidth: CGFloat =  (UIScreen.mainWidth() - 20 * 2 - 20 - 6 * emojiSpace) / 7
let emojiHeight: CGFloat = emojiWidth
protocol EmojiControlViewDelegate: NSObjectProtocol {
    func openEmojis()
    func openKeyword()
    func contentCardComment(emoji: Int)
}
class EmojiControlView: UIView {
    weak var delegate: EmojiControlViewDelegate?
    private lazy var roundedMaskView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white.withAlphaComponent(0.9)
        return view
    }()
    
    private lazy var openButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Open"), for: .normal)
        button.addTarget(self, action: #selector(openAction(sender:)), for: .touchUpInside)
        return button
    }()
    private lazy var keywordButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Keyword"), for: .normal)
        button.addTarget(self, action: #selector(keywordAction(sender:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var emojiImageViews: [UIImageView] = {
        var imageViews = [UIImageView]()
        for index in 1...6 {
            let imageView = UIImageView()
            imageView.image = UIImage(named: "Emoji\(index)")
            imageViews.append(imageView)
        }
        return imageViews
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.white
        setupDefaultUI()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reset(names: [String]) {
        clearUI()
        setupDefaultUI()
        updateDefault(names: names)
    }
    func updateDefault(names: [String]) {
        emojiImageViews[0].image = UIImage(named: names[0])
        emojiImageViews[1].image = UIImage(named: names[1])
    }
    func openEmojis() {
        clearUI()
        var insetX: CGFloat = 10
        let insetY: CGFloat = 5
        addSubview(keywordButton)
        keywordButton.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        for imageView in emojiImageViews {
            insetX += emojiSpace + emojiWidth
            addSubview(imageView)
            imageView.frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        }
    }
    
    private func setupDefaultUI() {
        clearUI()
        var insetX: CGFloat = 10
        let insetY: CGFloat = 5
        addSubview(emojiImageViews[0])
        emojiImageViews[0].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        insetX += emojiSpace + emojiWidth
        addSubview(emojiImageViews[1])
        emojiImageViews[1].frame = CGRect(x: insetX, y: insetY, width: emojiWidth, height: emojiHeight)
        insetX += emojiWidth
        addSubview(openButton)
        openButton.frame = CGRect(x: insetX, y: 12.5, width: 25, height: 25)
    }
    
    private func clearUI() {
        keywordButton.removeFromSuperview()
        openButton.removeFromSuperview()
        emojiImageViews.forEach { $0.removeFromSuperview() }
        openButton.removeFromSuperview()
    }
    
    @objc private func openAction(sender: UIButton) {
        delegate?.openEmojis()
    }
    
    @objc private func keywordAction(sender: UIButton) {
        delegate?.openKeyword()
    }
}
