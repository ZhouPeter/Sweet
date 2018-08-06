//
//  ShareWebViewController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ShareWebViewControllerDelegate: NSObjectProtocol {
    func showAllEmoji(cardId: String)
    func selectEmoji(emoji: Int, cardId: String, webView: ShareWebViewController)
    func showProfile(userId: UInt64, webView: ShareWebViewController)
}

class ShareWebViewController: WebViewController {
    weak var delegate: ShareWebViewControllerDelegate?
    private var shareCallback: (() -> Void)?
    private var cardId: String?
    var card: CardResponse?
    var emojiDisplay: EmojiViewDisplay = .show
    var navigationBarColors = [UIColor]()
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
    init(urlString: String, shareCallback: (() -> Void)?) {
        super.init(urlString: urlString)
        self.shareCallback = shareCallback
    }
    
    convenience init(urlString: String, cardId: String, shareCallback: (() -> Void)?) {
        self.init(urlString: urlString, shareCallback: shareCallback)
        self.cardId = cardId
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        requestFromCard()
        if navigationBarColors.count > 0 {
            setNavigationBackgroundImage()
        }
    }
    
    
    
    func updateEmojiView(card: CardResponse) {
        self.card = card
        resetEmojiView()
    }
    
    private func setNavigationBackgroundImage() {
        NotificationCenter.default.post(name: .WhiteStatusBar, object: nil)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
        navigationController?.navigationBar.setBackgroundGradientImage(colors: navigationBarColors)
        webViewTopConstraint?.constant = 0
    }
    
    private func requestFromCard() {
        if let cardId = cardId {
            web.request(WebAPI.getCard(cardID: cardId), responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.card  = response.card
                    self.setBottomView()
                case let .failure(error):
                    logger.debug(error)
                }
            }
        }
    }
    private func setBottomView() {
        let bottomView = UIView()
        bottomView.backgroundColor = .white
        if navigationBarColors.count > 0 {
            bottomView.layer.shadowOffset = CGSize(width: 0, height: -1)
            bottomView.layer.shadowColor = navigationBarColors[0].cgColor
            bottomView.layer.shadowOpacity = 0.66
        }
        view.addSubview(bottomView)
        bottomView.align(.left)
        bottomView.align(.right)
        bottomView.align(.bottom)
        bottomView.constrain(height: 50)
        bottomView.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left)
        emojiView.align(.bottom)
        emojiView.align(.top)
        bottomView.addSubview(shareButton)
        shareButton.constrain(width: 24, height: 24)
        shareButton.align(.left, inset: 10)
        shareButton.centerY(to: emojiView)
        resetEmojiView()
    }
    
    private func resetEmojiView() {
        if let card = card, card.cardEnumType == .content  {
            if card.video != nil {
                var viewModel = ContentVideoCardViewModel(model: card)
                viewModel.emojiDisplayType = emojiDisplay
                emojiView.update(indexs: viewModel.defaultEmojiList,
                                 resultImage: viewModel.resultImageName,
                                 resultAvatarURLs: viewModel.resultAvatarURLs,
                                 emojiType: viewModel.emojiDisplayType)
            } else {
                var viewModel = ContentCardViewModel(model: card)
                viewModel.emojiDisplayType = emojiDisplay
                emojiView.update(indexs: viewModel.defaultEmojiList,
                                 resultImage: viewModel.resultImageName,
                                 resultAvatarURLs: viewModel.resultAvatarURLs,
                                 emojiType: viewModel.emojiDisplayType)
                
            }
        }
    }
    
    @objc private func didPressShare(_ sender: UIButton) {
        shareCallback?()
    }
 
}

extension ShareWebViewController: EmojiControlViewDelegate {
    func openEmojis() {
        if let cardId = card?.cardId {
            emojiDisplay = .allShow
            delegate?.showAllEmoji(cardId: cardId)
        }
    }
    func selectEmoji(emoji: Int) {
        if let cardId = card?.cardId {
            delegate?.selectEmoji(emoji: emoji, cardId: cardId, webView: self)
        }
    }
    
    func didTapAvatar(index: Int) {
        if let card = card, card.cardEnumType == .content  {
            let viewModel = ContentCardViewModel(model: card)
            if let userIds = viewModel.resultUseIDs {
                delegate?.showProfile(userId: userIds[index], webView: self)
            }
        }
    }
}

