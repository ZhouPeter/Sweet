//
//  CardBaseController+CellDelegate.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import JXPhotoBrowser
import JDStatusBarNotification
import SDWebImage
// MARK: - ChoiceCardCollectionViewCellDelegate
extension CardsBaseController: ChoiceCardCollectionViewCellDelegate {
    
    func showProfile(buddyID: UInt64, setTop: SetTop? = nil) {
        delegate?.showProfile(buddyID: buddyID, setTop: setTop)
    }
    
    func selectChoiceCard(cardId: String, selectedIndex: Int) {
        web.request(
            .choiceCard(cardId: cardId, index: selectedIndex),
            responseType: Response<SelectResult>.self) { (result) in
                switch result {
                case let .success(response):
                    guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                    self.cards[index].result = response
                    let viewModel = ChoiceCardViewModel(model: self.cards[index])
                    let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
                    self.cellConfigurators[index] = configurator
                    self.mainView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    self.vibrateFeedback()
                    CardAction.clickPreference.actionLog(card: self.cards[index])
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
}
// MARK: - StoriesCardCollectionViewCellDelegate
extension CardsBaseController: StoriesCardCollectionViewCellDelegate, UsersCardCollectionViewCellDelegate {
    func showStoriesPlayerController(cell: UICollectionViewCell,
                                     storiesGroup: [[StoryCellViewModel]],
                                     currentIndex: Int,
                                     cardId: String?) {
        if let index = cards.index(where: { $0.cardId == cardId}) {
            if index != self.index {
                self.index = index
                mainView.scrollToIndex(index)
                return
            }
        }
        delegate?.showStoriesGroup(
            storiesGroup: storiesGroup,
            currentIndex: currentIndex,
            fromCardId: cardId,
            delegate: self,
            completion: {}
        )
        CardAction.clickStory.actionLog(card: cards[index])
    }
}
// MARK: - EvaluationCardCollectionViewCellDelegate
extension CardsBaseController: EvaluationCardCollectionViewCellDelegate {
    func selectEvaluationCard(cell: EvaluationCardCollectionViewCell, cardId: String, selectedIndex: Int) {
        web.request(.evaluateCard(cardId: cardId, index: selectedIndex)) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                guard let index = self.cards.index(where: { $0.cardId == cardId }),
                    self.cards[index].cardEnumType == .evaluation else { return }
                self.cards[index].result = SelectResult(contactUserList: [SelectResult.UserAvatar](),
                                                        index: selectedIndex,
                                                        percent: 0,
                                                        emoji: nil)
                let viewModel = EvaluationCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                logger.debug("评价完成")
                cell.updateWith(selectedIndex)
                if Defaults[.isEvaluationOthers] == false {
                    let alert = UIAlertController(title: nil,
                                                  message: "你的好友将会收到你的评价",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "知道了", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                } else {
                    self.toast(message: "❤️评价成功")
                }
                Defaults[.isEvaluationOthers] = true
                self.vibrateFeedback()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}
// MARK: - ContentCardCollectionViewCellDelegate
extension CardsBaseController: ContentCardCollectionViewCellDelegate {
    func joinGroup(groupId: UInt64, cardId: String, contentId: String) {
        joinGroup(text: "")
    }

    func shareCard(cardId: String) {
        if let index = cards.index(where: { $0.cardId == cardId }) {
            let card  = self.cards[index]
            shareCard(card: card)
        }
    }
    
    func contentCardComment(cardId: String, emoji: Int) {
        web.request(
            .commentCard(cardId: cardId, emoji: emoji),
            responseType: Response<SelectResult>.self) { (result) in
                guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                switch result {
                case let .success(response):
                    self.cards[index].result = response
                    self.reloadContentCell(index: index)
                    self.vibrateFeedback()
                    CardAction.clickComment.actionLog(card: self.cards[index])
                    if Defaults[.isSameCardChoiceGuideShown] == false && response.contactUserList.count > 0 {
                        let rect = CGRect(x: UIScreen.mainWidth() - (20 + 32 + 8 + 1 + 8 - 4) - CGFloat(response.contactUserList.count) * 40,
                                          y: UIScreen.navBarHeight() + 10 + cardCellHeight - 50 - 5 ,
                                          width: CGFloat(response.contactUserList.count) * 40,
                                          height: 40)
                        Guide.showSameCardChoiceTip(with: rect)
                        Defaults[.isSameCardChoiceGuideShown] = true
                    }
                case let .failure(error):
                    self.reloadContentCell(index: index)
                    logger.error(error)
                }
        }
    }
    
    func openEmojis(cardId: String) {
        guard let index = cards.index(where: { $0.cardId == cardId }) else { return }
        showCellEmojiView(emojiDisplayType: .allShow, index: index)
    
    }
    
    func showImageBrowser(selectedIndex: Int) {
        showBrower(index: index, originPageIndex: selectedIndex)
    }
}

extension CardsBaseController: GameCardCollectionViewCellDelegate {
    func changeViewModel(_ viewModel: GameCardViewModel) {
        guard let index = cards.index(where: { $0.cardId == viewModel.cardId }) else { return }
        let configurator = CellConfigurator<GameCardCollectionViewCell>(viewModel: viewModel)
        cellConfigurators[index] = configurator
    }
}
// MARK: - BaseCardCollectionViewCellDelegate
extension CardsBaseController: BaseCardCollectionViewCellDelegate {
    func showAlertController(cardId: String, fromCell: BaseCardCollectionViewCell) {
        guard  let index = cards.index(where: { $0.cardId == cardId }) else { return }
        let cardType = cards[index].cardEnumType
        if cardType == .activity {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction.makeAlertAction(title: "投诉", style: .destructive) { (_) in
                web.request(.cardReport(cardId: cardId), completion: { (result) in
                    switch result {
                    case .success:
                        JDStatusBarNotification.show(withStatus: "已经收到反馈", dismissAfter: 2)
                    case .failure:
                        JDStatusBarNotification.show(withStatus: "反馈失败，请稍后重试。", dismissAfter: 2)
                    }
                })
            }
            let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
            alert.addAction(reportAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        let sectionId = cards[index].sectionId!
        web.request(.sectionStatus(sectionId: sectionId),
                    responseType: Response<StatusResponse>.self) { (result) in
                        switch result {
                        case let .success(response):
                            let alert = self.makeAlertController(status: response,
                                                                 cardType: cardType,
                                                                 cardId: cardId,
                                                                 sectionId: sectionId)
                            self.present(alert, animated: true, completion: nil)
                        case let .failure(error):
                            logger.error(error)
                    }
        }
    }
}
// MARK: - StoriesPlayerGroupViewControllerDelegate
extension CardsBaseController: StoriesPlayerGroupViewControllerDelegate {
    func updateStory(story: StoryCellViewModel, postion: (Int, Int)) {
        guard self.cards[index].cardEnumType == .story else { return }
        guard var configurator = cellConfigurators[index] as? CellConfigurator<StoriesCardCollectionViewCell> else {
            return
        }
        configurator.viewModel.updateStory(story: story, postion: postion)
        cellConfigurators[index] = configurator
        self.mainView.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
    }
    
}
// MARK: - ActivitiesCardCollectionViewCellDelegate
extension CardsBaseController: ActivitiesCardCollectionViewCellDelegate {
    func showWebController(url: String, content: String) {
        let controller = WebViewController(urlString: url)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension CardsBaseController {
    private func showBrower(index: Int, originPageIndex: Int) {
        guard let configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell>
            else { return }
        guard let cell = mainView.collectionView.cellForItem(at: IndexPath(item: self.index, section: 0))
            as? ContentCardCollectionViewCell else { return  }
        let imageIcon = cell.imageIcons[originPageIndex]
        let imageURLs = configurator.viewModel.imageURLList!
        if  imageIcon.titleLabel?.text == "GIF", imageIcon.isHidden == false {
            let imageView = cell.imageViews[originPageIndex]
            imageIcon.isHidden = true
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                imageView.sd_setImage(with: imageURLs[originPageIndex])
            }
        }
        let shareText: String? = String.getShareText(content: cards[index].content, url: cards[index].url)
        photoBrowserImp = PhotoBrowserImp(thumbnaiImageViews: cell.imageViews,
                                          highImageViewURLs: imageURLs,
                                          shareText: shareText)
        let browser = CustomPhotoBrowser(delegate: photoBrowserImp,
                                         photoLoader: SDWebImagePhotoLoader(),
                                         originPageIndex: originPageIndex)
        browser.animationType = .scale
        browser.plugins.append(CustomNumberPageControlPlugin())
        browser.plugins.append(CustomChangeBrowerPlugin(card: cards[index]))
        browser.show()
        CardAction.clickImg.actionLog(card: cards[index])
    }
}

extension CardsBaseController {
    private func showCellEmojiView(emojiDisplayType: EmojiViewDisplay, index: Int) {
        if cards[index].cardEnumType == .content  {
            if var configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
            if var configurator = cellConfigurators[index] as? CellConfigurator<VideoCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
            if var configurator = cellConfigurators[index] as? CellConfigurator<LongTextCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
        }
    }
}

extension CardsBaseController: VideoCardCollectionViewCellDelegate {
    func showVideoPlayerController(playerView: SweetPlayerView, cardId: String) {
        guard let index = cards.index(where: { $0.cardId == cardId }) else { return }
        guard index == self.index else { return }
        playerView.playerLayer?.hero.id = cards[index].video
        playerView.playerLayer?.hero.modifiers = [.arc, .useScaleBasedSizeChange]
        let controller = PlayController()
        if let avPlayer = playerView.avPlayer {
            controller.avPlayer = avPlayer
        } else {
            VideoCardPlayerManager.shared.play(with: URL(string: cards[index].video!)!)
            controller.avPlayer = VideoCardPlayerManager.shared.player
        }
        controller.hero.isEnabled = true
        controller.resource = playerView.resource
        self.present(controller, animated: true, completion: nil)
        isVideoMuted = false
        playerView.isVideoMuted = isVideoMuted
        CardAction.clickVideo.actionLog(card: cards[index])
    }
}

extension CardsBaseController: SweetPlayerViewDelegate {
    func sweetPlayer(player: SweetPlayerView, playerStateDidChange state: SweetPlayerState) {
        if let indexPath = player.resource.indexPath, state == .readyToPlay {
            if let cell = mainView.collectionView.cellForItem(at: indexPath) as? VideoCardCollectionViewCell {
               cell.contentImageView.image = nil
            }
        }
        if state == .playedToTheEnd {
            CardAction.playEnd.actionLog(card: cards[index])
        }
    }
    func sweetPlayer(player: SweetPlayerView, isMuted: Bool) {
       isVideoMuted = isMuted
    }
    
    func sweetPlayer(player: SweetPlayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        if let indexPath = player.resource.indexPath {
            if cards[indexPath.row].cardEnumType == .content || cards[indexPath.row].cardEnumType == .groupChat,
                cards[indexPath.row].video != nil {
                if currentTime == 10 {
                    CardAction.play10s.actionLog(card: cards[indexPath.row])
                }
                if var configurator = cellConfigurators[indexPath.row] as? CellConfigurator<VideoCardCollectionViewCell> {
                    configurator.viewModel.currentTime = currentTime
                    cellConfigurators[indexPath.row] = configurator
                }
            }
        }
    }
}

extension CardsBaseController: ShareWebViewControllerDelegate {
    func showProfile(userId: UInt64, webView: ShareWebViewController) {
        showProfile(buddyID: userId)
    }
    
    func showAllEmoji(cardId: String) {
        openEmojis(cardId: cardId)
        guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
        self.updateContentCellEmoji(index: index)
    }
    func reloadContentEmoji(card: CardResponse) {
        guard let index = self.cards.index(where: { $0.cardId == card.cardId }) else { return }
        self.cards[index] = card
        self.reloadContentCell(index: index)
    }
}

extension CardsBaseController: MessengerDelegate {
    func messengerDidQuitGroup(_ groupID: UInt64, success: Bool) {
        guard success else { return }
        for (index, card) in cards.enumerated() where card.cardEnumType == .groupChat && card.groupId! == groupID {
            cards[index].join = false
        }
    }
}
