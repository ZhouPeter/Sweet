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
                    web.request(.delSectionSubscription(sectionId: sectionId), completion: { (_) in })
                } else {
                    web.request(.addSectionSubscription(sectionId: sectionId), completion: { (_) in })
                }
        }
        let blockAction = UIAlertAction.makeAlertAction(
            title: status.block ? "取消屏蔽" : "屏蔽该栏目",
            style: .default) { (_) in
                if status.block {
                    web.request(.delSectionBlock(sectionId: sectionId), completion: { (_) in })
                } else {
                    web.request(.addSectionBlock(sectionId: sectionId), completion: { (_) in })
                }
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(subscriptionAction)
        alertController.addAction(blockAction)
        alertController.addAction(cancelAction)
        return alertController
    }
    
    func appendConfigurator(card: CardResponse) {
        switch card.type {
        case .content:
            if card.video != nil {
                let viewModel = ContentVideoCardViewModel(model: card)
                let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
                cellConfigurators.append(configurator)
                cards.append(card)
            } else {
                let viewModel = ContentCardViewModel(model: card)
                let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
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
                    self?.showProfile(userId: userId)
                }
                viewModel.storyCellModels[offset] = cellModel
            }
            let configurator = CellConfigurator<StoriesCardCollectionViewCell>(viewModel: viewModel)
            cellConfigurators.append(configurator)
            cards.append(card)
        default: break
        }
    }
    

    func reloadContentCell(index: Int) {
        if self.cards[index].type == .content, self.cards[index].video == nil {
            let viewModel = ContentCardViewModel(model: self.cards[index])
            let configurator = CellConfigurator<ContentCardCollectionViewCell>(viewModel: viewModel)
            self.cellConfigurators[index] = configurator
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
        } else if self.cards[index].type == .content, self.cards[index].video != nil {
            let viewModel = ContentVideoCardViewModel(model: self.cards[index])
            let configurator = CellConfigurator<VideoCardCollectionViewCell>(viewModel: viewModel)
            self.cellConfigurators[index] = configurator
            self.collectionView.reloadItems(at: [IndexPath(item: index, section: 0)])
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
    
    func sendMessge(cardId: String, text: String, userIds: [UInt64]) {
        guard let index = cards.index(where: { $0.cardId == cardId }) else {fatalError()}
        let card  = cards[index]
        let from = UInt64(Defaults[.userID]!)!
        if let content = MessageContentHelper.getContentCardContent(resultCard: card) {
            if card.type == .content, let content = content as? ContentCardContent {
                userIds.forEach {
                    Messenger.shared.sendContentCard(content, from: from, to: $0, extra: cardId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                    web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                }
            } else if card.type == .choice, let content = content as? OptionCardContent {
                userIds.forEach {
                    Messenger.shared.sendPreferenceCard(content, from: from, to: $0, extra: cardId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: $0) }
                    web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                }
            } else if card.type == .evaluation, let content = content as? OptionCardContent {
                userIds.forEach {
                    Messenger.shared.sendEvaluationCard(content, from: from, to: $0, extra: cardId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                    web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                }
            }
        }
        NotificationCenter.default.post(name: .dismissShareCard, object: nil)
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

extension CardsBaseController: MessengerDelegate {
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        if success {
            if message.type == .card {
                JDStatusBarNotification.show(withStatus: "转发成功", dismissAfter: 2)
            } else if message.type == .like || message.type == .text {
                JDStatusBarNotification.show(withStatus: "赞评成功", dismissAfter: 2)
            }
        } else {
            if message.type == .card {
                JDStatusBarNotification.show(withStatus: "转发失败", dismissAfter: 2)
            } else if message.type == .like || message.type == .text {
                JDStatusBarNotification.show(withStatus: "赞评失败", dismissAfter: 2)
            }
        }
    }
}

// MARK: - ActivityMessage Methods
extension CardsBaseController {
    func sendActivityMessages(text: String) {
        let card = cards[index]
        let from = UInt64(Defaults[.userID]!)!
        guard let cardId = activityCardId, let activityId = activityId else { return }
        guard card.type == .activity, card.cardId == cardId else { return }
        guard let index = card.activityList!.index(where: { $0.activityId == activityId }) else {fatalError()}
        let toUserId = card.activityList![index].actor
        let cardID = card.activityList![index].fromCardId
        web.request(
            WebAPI.getCard(cardID: cardID),
            responseType: Response<CardGetResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    let resultCard = response.card
                    if let content = MessageContentHelper.getContentCardContent(resultCard: resultCard) {
                        if resultCard.type == .content, let content = content as? ContentCardContent {
                            Messenger.shared.sendContentCard(content, from: from, to: toUserId, extra: activityId)
                        } else if resultCard.type == .choice, let content = content as? OptionCardContent {
                            Messenger.shared.sendPreferenceCard(content, from: from, to: toUserId, extra: activityId)
                        }
                    } else {
                        return
                    }
                    Messenger.shared.sendLike(from: from, to: toUserId, extra: activityId)
                    if text != "" { Messenger.shared.sendText(text, from: from, to: toUserId, extra: activityId) }
                    self.requestActivityCardLike(cardId: cardId, activityId: activityId, comment: text)
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
                self.cards[index].activityList![item].like = true
                let viewModel = ActivitiesCardViewModel(model: self.cards[index])
                let configurator = CellConfigurator<ActivitiesCardCollectionViewCell>(viewModel: viewModel)
                self.cellConfigurators[index] = configurator
                if let cell = self.collectionView.cellForItem(at: IndexPath(row: index, section: 0)),
                    let acCell = cell as? ActivitiesCardCollectionViewCell {
                    acCell.updateItem(item: item, like: true)
                }
                self.vibrateFeedback()
            case let  .failure(error):
                logger.error(error)
            }
        }
    }
}
