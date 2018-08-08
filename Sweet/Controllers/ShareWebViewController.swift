//
//  ShareWebViewController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/6.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ShareWebViewControllerDelegate: class {
    func showAllEmoji(cardId: String)
    func reloadContentEmoji(card: CardResponse)
    func showProfile(userId: UInt64, webView: ShareWebViewController)
}

extension ShareWebViewControllerDelegate {
    func showAllEmoji(cardId: String) {}
    func reloadContentEmoji(card: CardResponse) {}
}

protocol ShareWebView: BaseView {
    var delegate: ShareWebViewControllerDelegate? { get set }
}

class ShareWebViewController: WebViewController, ShareWebView {
    weak var delegate: ShareWebViewControllerDelegate?
    
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
    
    init(urlString: String, cardId: String) {
        self.cardId = cardId
        super.init(urlString: urlString)
    }
    
    init(urlString: String, card: CardResponse) {
        self.card = card
        super.init(urlString: urlString)
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
        if card == nil, let cardId = cardId {
            web.request(
                 WebAPI.getCard(cardID: cardId),
                 responseType: Response<CardGetResponse>.self) { (result) in
                    switch result {
                    case let .success(response):
                        self.card = response.card
                        self.setBottomView()
                    case let .failure(error):
                        logger.error(error)
                    }
            }
        } else {
            setBottomView()
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
        bottomView.constrain(height: 50 + UIScreen.safeBottomMargin())
        bottomView.addSubview(emojiView)
        emojiView.align(.right)
        emojiView.align(.left)
        emojiView.align(.bottom, inset: UIScreen.safeBottomMargin())
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
        if let card = card {
            shareCard(card: card)
        }
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
        if let card = card {
            web.request(
                .commentCard(cardId: card.cardId, emoji: emoji),
                responseType: Response<SelectResult>.self) { (result) in
                    switch result {
                    case let .success(response):
                        self.card!.result = response
                        self.updateEmojiView(card: self.card!)
                        self.vibrateFeedback()
                        CardAction.clickComment.actionLog(card: self.card!)
                        self.delegate?.reloadContentEmoji(card: self.card!)
                    case let .failure(error):
                        logger.error(error)
                    }
            }
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

