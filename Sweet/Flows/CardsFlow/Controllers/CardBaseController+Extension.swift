//
//  CardBaseController+Extension.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import JDStatusBarNotification
extension CardsBaseController {
    func makeAlertController(status: StatusResponse,
                                     cardType: CardResponse.CardType,
                                     cardId: String,
                                     sectionId: UInt64) -> UIAlertController {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let subscriptionAction = UIAlertAction.makeAlertAction(
            title: status.subscription ? "取消订阅" : "订阅该栏目",
            style: .default) { (_) in
                if status.subscription {
                    web.request(.delSectionSubscription(sectionId: sectionId), completion: {
                        switch $0 {
                        case .success: JDStatusBarNotification.show(withStatus: "已取消订阅", dismissAfter: 2)
                        case .failure: break
                        }
                    })
                } else {
                    web.request(.addSectionSubscription(sectionId: sectionId), completion: {
                        switch $0 {
                        case .success: JDStatusBarNotification.show(withStatus: "订阅成功", dismissAfter: 2)
                        case .failure: break
                        }
                    })
                }
        }
       
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(subscriptionAction)
        if cardType != .evaluation {
            let blockAction = UIAlertAction.makeAlertAction(
                title: status.block ? "取消屏蔽" : "屏蔽该栏目",
                style: .default) { (_) in
                    if status.block {
                        web.request(.delSectionBlock(sectionId: sectionId), completion: {
                            switch $0 {
                            case .success: JDStatusBarNotification.show(withStatus: "恢复推送该栏目的内容", dismissAfter: 2)
                            case .failure: break
                            }
                        })
                    } else {
                        web.request(.addSectionBlock(sectionId: sectionId), completion: {
                            switch $0 {
                            case .success: JDStatusBarNotification.show(withStatus: "不再推送该栏目的内容", dismissAfter: 2)
                            case .failure: break
                            }
                        })
                    }
            }
            alertController.addAction(blockAction)
        }
        if cardType == .content {
            let reportAction = UIAlertAction.makeAlertAction(title: "内容投诉", style: .default) { (_) in
                web.request(.cardReport(cardId: cardId), completion: {
                    switch $0 {
                    case .success: JDStatusBarNotification.show(withStatus: "已经收到反馈", dismissAfter: 2)
                    case .failure: break
                    }
                })
            }
            alertController.addAction(reportAction)
        }
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func appendConfigurator(card: CardResponse) {
        switch card.cardEnumType {
        case .content:
            if card.video != nil {
                let viewModel = ContentVideoCardViewModel(model: card)
                let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            } else if let count = card.imageList?.count, count > 0 {
                let viewModel = ContentCardViewModel(model: card)
                let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            } else if card.thumbnail != nil {
                let viewModel = LongTextCardViewModel(model: card)
                let configurator = CellConfigurator<LongTextCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            }
        case .choice:
            let viewModel = ChoiceCardViewModel(model: card)
            let configurator = CellConfigurator<ChoiceCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .evaluation:
            let viewModel = EvaluationCardViewModel(model: card)
            let configurator = CellConfigurator<EvaluationCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .activity:
            var viewModel = ActivitiesCardViewModel(model: card)
            for(offset, var activityViewModel) in viewModel.activityViewModels.enumerated() {
                activityViewModel.callBack = { [weak self] activityId in
                    self?.showInputView(cardId: viewModel.cardId, activityId: activityId)
                }
                activityViewModel.showProfile = { [weak self] (buddyID, setTop) in
                    CardAction.clickAvatar.actionLog(card: card, toUserId: String(buddyID))
                    self?.showProfile(userId: buddyID, setTop: setTop)
                }
                viewModel.activityViewModels[offset] = activityViewModel
            }
            let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .story:
            var viewModel = StoriesCardViewModel(model: card)
            for (offset, var cellModel) in viewModel.storyCellModels.enumerated() {
                cellModel.callback = { [weak self] userId in
                    CardAction.clickAvatar.actionLog(card: card, toUserId: String(userId))
                    self?.showProfile(userId: userId)
                }
                viewModel.storyCellModels[offset] = cellModel
            }
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        case .welcome:
            let viewModel = WelcomeCardViewModel(model: card, user: user)
            let configurator = CellConfigurator<WelcomeCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        default:
            logger.debug(card)
            break
        }
    }
    
    func updateContentCellEmoji(index: Int) {
        if self.cards[index].cardEnumType == .content, self.cards[index].video == nil, self.cards[index].imageList?.count ?? 0 > 0 {
            guard let configurator = cellConfigurators[index] as? CellConfigurator<ContentCardCollectionViewCell> else { return }
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ContentCardCollectionViewCell {
                cell.updateEmojiView(viewModel: configurator.viewModel)
            }
        } else if self.cards[index].cardEnumType == .content, self.cards[index].video != nil {
            guard let configurator = cellConfigurators[index] as? CellConfigurator<VideoCardCollectionViewCell> else { return }
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCardCollectionViewCell {
                cell.updateEmojiView(viewModel: configurator.viewModel)
            }
        } else if self.cards[index].cardEnumType == .content, self.cards[index].thumbnail != nil {
            guard let configurator = cellConfigurators[index] as? CellConfigurator<LongTextCardCollectionViewCell> else { return }
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? LongTextCardCollectionViewCell {
                cell.updateEmojiView(viewModel: configurator.viewModel)
            }
        }
    }
    
    func reloadContentCell(index: Int) {
        if self.cards[index].cardEnumType == .content, self.cards[index].video == nil, self.cards[index].imageList?.count ?? 0 > 0 {
            let viewModel = ContentCardViewModel(model: self.cards[index])
            let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
            self.cellConfigurators[index] = configurator
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? ContentCardCollectionViewCell {
                cell.updateEmojiView(viewModel: viewModel)
            }
        } else if self.cards[index].cardEnumType == .content, self.cards[index].video != nil {
            let viewModel = ContentVideoCardViewModel(model: self.cards[index])
            let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
            self.cellConfigurators[index] = configurator
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? VideoCardCollectionViewCell {
                cell.updateEmojiView(viewModel: viewModel)
            }
        } else if self.cards[index].cardEnumType == .content, self.cards[index].thumbnail != nil {
            let viewModel = LongTextCardViewModel(model: self.cards[index])
            let configurator = CellConfigurator<LongTextCardCollectionViewCell>(viewModel: viewModel)
            self.cellConfigurators[index] = configurator
            if let cell = mainView.collectionView.cellForItem(at: IndexPath(item: index, section: 0)) as? LongTextCardCollectionViewCell {
                cell.updateEmojiView(viewModel: viewModel)
            }
        }
    }
}
// MARK: - Private Methods
extension CardsBaseController {
    private func showInputView(cardId: String, activityId: String) {
        let window = UIApplication.shared.keyWindow!
        window.addSubview(inputTextView)
        inputTextView.fill(in: window)
        inputTextView.startEditing(isStarted: true)
        self.activityId = activityId
        self.activityCardId = cardId
    }
}

// MARK: - InputTextViewDelegate
extension CardsBaseController: InputTextViewDelegate {
    func inputTextViewDidPressSendMessage(text: String) {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
        sendActivityMessages(text: text)
        
    }
    
    func removeInputTextView() {
        inputTextView.clear()
        inputTextView.removeFromSuperview()
    }
}

// MARK: - ActivityMessage Methods
extension CardsBaseController {
    func sendActivityMessages(text: String) {
        let card = cards[index]
        guard let cardId = activityCardId, let activityId = activityId else { return }
        guard card.cardEnumType == .activity, card.cardId == cardId else { return }
        guard let index = card.activityList!.index(where: { $0.activityId == activityId }) else {fatalError()}
        let toUserId = card.activityList![index].actor
        let cardID = card.activityList![index].fromCardId
        web.request(
            WebAPI.getCard(cardID: cardID),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let resultCard = response.card
                    CardMessageManager.shard.sendMessage(card: resultCard, text: text, userIds: [toUserId], extra: activityId)
                    self.requestActivityCardLike(cardId: cardId, activityId: activityId, comment: text)
//                    if Defaults[.isInputTextSendMessage] == false {
//                        let alert = UIAlertController(title: nil, message: "消息将出现在对话列表中", preferredStyle: .alert)
//                        alert.addAction(UIAlertAction(title: "知道了", style: .cancel, handler: nil))
//                        self.present(alert, animated: true, completion: nil)
//                    } else {
//                        self.toast(message: "💗消息发送成功")
//                    }
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    private func requestActivityCardLike(cardId: String, activityId: String, comment: String) {
        web.request(.activityCardLike(cardId: cardId, activityId: activityId, comment: comment)) { (result) in
            switch result {
            case .success:
                guard let index = self.cards.index(where: { $0.cardId == cardId }) else { return }
                guard let item = self.cards[index].activityList!.index(
                    where: { $0.activityId == activityId }) else { return }
                guard var configurator = self.cellConfigurators[index] as? CellConfigurator<ActivitiesCardCollectionViewCell> else {
                    return
                }
                self.cards[index].activityList![item].like = true
                configurator.viewModel.activityViewModels[item].like = true
                self.cellConfigurators[index] = configurator
                if let cell = self.mainView.collectionView.cellForItem(at: IndexPath(row: index, section: 0)),
                    let acCell = cell as? ActivitiesCardCollectionViewCell {
                    acCell.updateItem(item: item, like: true)
                }
                CardAction.likeActivity.actionLog(card: self.cards[index],
                                                  activityId: self.cards[index].activityList![item].activityId)
                self.vibrateFeedback()
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
