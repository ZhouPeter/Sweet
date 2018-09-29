//
//  CardMessageManager.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
class CardMessageManager {
    static let shard = CardMessageManager()
    private init () {}
    func sendMessage(card: CardResponse, text: String, userIds: [UInt64]) {
        let cardId  = card.cardId
        let from = UInt64(Defaults[.userID]!)!
        MessageContentHelper.getContentCardContent(resultCard: card) { (content) in
            if card.cardEnumType == .content || card.cardEnumType == .groupChat {
                if let content = content as? ContentCardContent {
                    userIds.forEach {
                        waitingIMNotifications.append(
                            Messenger.shared.sendContentCard(content, from: from, to: $0, extra: cardId)
                        )
                        if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                        web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                    }
                } else if let content = content as? ArticleMessageContent {
                    userIds.forEach {
                        waitingIMNotifications.append(
                            Messenger.shared.sendArtice(content, from: from, to: $0, extra: cardId)
                        )
                        if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                        web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                    }
                }
                
            } else if card.cardEnumType == .choice, let content = content as? OptionCardContent {
                userIds.forEach {
                    waitingIMNotifications.append(
                        Messenger.shared.sendPreferenceCard(content, from: from, to: $0, extra: cardId)
                    )
                    if text != "" { Messenger.shared.sendText(text, from: from, to: $0) }
                    web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                }
            } else if card.cardEnumType == .evaluation, let content = content as? OptionCardContent {
                userIds.forEach {
                    waitingIMNotifications.append(
                        Messenger.shared.sendEvaluationCard(content, from: from, to: $0, extra: cardId)
                    )
                    if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: cardId) }
                    web.request(.shareCard(cardId: cardId, comment: text, userId: $0), completion: {_ in })
                }
            }
            NotificationCenter.default.post(name: .dismissShareCard, object: nil)
        }
    }
    func sendMessage(card: CardResponse, text: String, userIds: [UInt64], extra: String) {
        let from = UInt64(Defaults[.userID]!)!
        MessageContentHelper.getContentCardContent(resultCard: card) { (content) in
            if card.cardEnumType == .content || card.cardEnumType == .groupChat {
                if let content = content as? ContentCardContent {
                    userIds.forEach {
                        Messenger.shared.sendContentCard(content, from: from, to: $0, extra: extra)
                    }
                } else if let content = content as? ArticleMessageContent {
                    userIds.forEach {
                        Messenger.shared.sendArtice(content, from: from, to: $0, extra: extra)
                    }
                }
            } else if card.cardEnumType == .choice, let content = content as? OptionCardContent {
                userIds.forEach {
                    Messenger.shared.sendPreferenceCard(content, from: from, to: $0, extra: extra)
                }
            }
            userIds.forEach {
                waitingIMNotifications.append(
                    Messenger.shared.sendLike(from: from, to: $0, extra: extra)
                )
                if text != "" { Messenger.shared.sendText(text, from: from, to: $0, extra: extra) }
            }
        }
    }
}
