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

// MARK: - ChoiceCardCollectionViewCellDelegate
extension CardsBaseController: ChoiceCardCollectionViewCellDelegate {
    
    func showProfile(userId: UInt64, setTop: SetTop? = nil) {
        delegate?.showProfile(userId: userId, setTop: setTop)
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
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                    self.vibrateFeedback()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
}
// MARK: - StoriesCardCollectionViewCellDelegate
extension CardsBaseController: StoriesCardCollectionViewCellDelegate {
    func showStoriesPlayerController(cell: UICollectionViewCell,
                                     storiesGroup: [[StoryCellViewModel]],
                                     currentIndex: Int,
                                     cardId: String?) {
        if let index = cards.index(where: { $0.cardId == cardId}) {
            if index != self.index {
                self.index = index
                scrollTo(row: self.index)
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
                    self.cards[index].type == .evaluation else { return }
                self.cards[index].result = SelectResult(contactUserList: [SelectResult.UserAvatar](),
                                                        index: selectedIndex,
                                                        percent: 0,
                                                        emoji: nil)
                let viewModel = EvaluationCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                logger.debug("评价完成")
                cell.updateWith(selectedIndex)
                if !Defaults[.isEvaluationOthers] {
                    let alert = UIAlertController(title: "你的好友将会收到你的评价",
                                                  message: "下次不再提示",
                                                  preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
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
    func shareCard(cardId: String) {
        if let index = self.cards.index(where: { $0.cardId == cardId }) {
            let text = self.cards[index].content! + self.cards[index].url! + "\n" + "\n"
                + "讲真APP，你的同学都在玩：" + "\n"
                + "[机智]http://t.cn/RrXTSg5"
            let controller = ShareCardController(shareText: text)
            controller.sendCallback = { (text, userIds) in
                self.sendMessge(cardId: cardId, text: text, userIds: userIds)
            }
            self.present(controller, animated: true, completion: nil)
        }
    }
    
    func contentCardComment(cardId: String, emoji: Int) {
        web.request(
            .commentCard(cardId: cardId, comment: "", emoji: emoji),
            responseType: Response<SelectResult>.self) { (result) in
                switch result {
                case let .success(response):
                    guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                    self.cards[index].result = response
                    self.reloadContentCell(index: index)
                    self.vibrateFeedback()
                    if Defaults[.isSameCardChoiceGuideShown] == false && response.contactUserList.count > 0 {
                        let rect = CGRect(x: 20 + 32 + 8 + 1 + 8 - 4,
                                          y: UIScreen.navBarHeight() + 10 + cardCellHeight - 50 - 5 ,
                                          width: CGFloat(response.contactUserList.count) * 40,
                                          height: 40)
                        Guide.showSameCardChoiceTip(with: rect)
                        Defaults[.isSameCardChoiceGuideShown] = true
                    }
                case let .failure(error):
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
// MARK: - BaseCardCollectionViewCellDelegate
extension CardsBaseController: BaseCardCollectionViewCellDelegate {
    func showAlertController(cardId: String, fromCell: BaseCardCollectionViewCell) {
        guard  let index = cards.index(where: { $0.cardId == cardId }) else { return }
        let cardType = cards[index].type
        if cardType == .activity {
            let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let reportAction = UIAlertAction.makeAlertAction(title: "投诉", style: .destructive) { (_) in
                web.request(.cardReport(cardId: cardId), completion: { (_) in })
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
    func readGroup(storyId: UInt64, fromCardId: String?, storyGroupIndex: Int) {
        if self.cards[index].type == .story {
            web.request(.storyRead(storyId: storyId, fromCardId: fromCardId)) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .success:
                    if storyGroupIndex > 3 { return }
                    guard let index = self.cards.index(where: { $0.cardId == fromCardId }) else { return }
                    let storys = self.cards[index].storyList![storyGroupIndex]
                    var newStorys = [StoryResponse]()
                    for var story in storys {
                        story.read = true
                        newStorys.append(story)
                    }
                    self.cards[index].storyList![storyGroupIndex] = newStorys
                    var viewModel = StoriesCardViewModel(model: self.cards[index])
                    viewModel.storyCellModels[storyGroupIndex].isRead = true
                    let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
                    self.cellConfigurators[index] = configurator
                    self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
                case let .failure(error):
                    logger.error(error)
                }
            }
        }
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
        guard let cell = collectionView.cellForItem(at: IndexPath(item: self.index, section: 0))
            as? ContentCardCollectionViewCell else { return  }
        let imageURLs = configurator.viewModel.imageURLList!
        self.photoBrowserImp = PhotoBrowserImp(thumbnaiImageViews: cell.imageViews, highImageViewURLs: imageURLs)
        let browser = PhotoBrowser(delegate: photoBrowserImp, originPageIndex: originPageIndex)
        browser.animationType = .scale
        browser.plugins.append(CustomNumberPageControlPlugin())
        browser.show()
    }
}

extension CardsBaseController {
    private func showCellEmojiView(emojiDisplayType: EmojiViewDisplay, index: Int) {
        if cards[index].type == .content  {
            if var configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
            if var configurator = cellConfigurators[index] as? CellConfigurator<VideoCardCollectionViewCell> {
                configurator.viewModel.emojiDisplayType = emojiDisplayType
                cellConfigurators[index] = configurator
            }
        }
    }
}

extension CardsBaseController: SweetPlayerViewDelegate {
    func sweetPlayer(player: SweetPlayerView, isMuted: Bool) {
        if let indexPath = player.resource.indexPath {
            if cards[indexPath.row].type == .content, cards[indexPath.row].video != nil {
                if var configurator = cellConfigurators[indexPath.row] as? CellConfigurator<VideoCardCollectionViewCell> {
                    configurator.viewModel.isMuted = isMuted
                    cellConfigurators[indexPath.row] = configurator
                }
            }
        }
    }
    
    func sweetPlayer(player: SweetPlayerView, playTimeDidChange currentTime: TimeInterval, totalTime: TimeInterval) {
        if let indexPath = player.resource.indexPath {
            if cards[indexPath.row].type == .content, cards[indexPath.row].video != nil {
                if var configurator = cellConfigurators[indexPath.row] as? CellConfigurator<VideoCardCollectionViewCell> {
                    configurator.viewModel.currentTime = currentTime
                    cellConfigurators[indexPath.row] = configurator
                }
            }
        }
    }
}
