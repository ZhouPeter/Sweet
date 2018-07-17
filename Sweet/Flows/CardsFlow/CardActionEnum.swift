//
//  CardActionEnum.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/17.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum CardAction: String {
    case clickImg = "click_img"
    case clickUrl = "click_url"
    case clickAll = "click_all"
    case playEnd = "play_end"
    case clickUrlBack = "click_url_back"
    case clickComment = "click_comment"
    case clickPreference = "click_preference"
    private func makeActionLogWebApi(card: CardResponse) -> WebAPI {
        let preferenceId: String? = card.preferenceId == nil ? nil : String(card.preferenceId!)
        return WebAPI.cardActionLog(action: rawValue,
                                    cardId: card.cardId,
                                    sectionId: String(card.sectionId!),
                                    contentId: card.contentId,
                                    preferenceId: preferenceId)
    }
    
    func actionLog(card: CardResponse) {
        let actionApi = makeActionLogWebApi(card: card)
        web.request(actionApi) { (result) in
            switch result {
            case .success:
                logger.debug(self.rawValue, " actionLog success")
            case let .failure(error):
                logger.debug(error, self.rawValue + " actionLog failure")
            }
        }
    }
}


