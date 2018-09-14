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
    case clickVideo = "click_video"
    case clickUrl = "click_url"
    case clickAll = "click_all"
    case playEnd = "play_end"
    case clickUrlBack = "click_url_back"
    case clickComment = "click_comment"
    case clickPreference = "click_preference"
    case likeStory = "like_story"
    case likeActivity = "like_activity"
    case clickAvatar = "click_avatar"
    case clickStory = "click_story"
    case shareStory = "share_story"
    case shareWeixin = "share_weixin"
    case shareQQ = "share_qq"
    case shareQZ = "share_qzone"
    case shareWeibo = "share_weibo"
    private func makeActionLogWebApi(card: CardResponse,
                                     toUserId: String? = nil,
                                     activityId: String? = nil,
                                     storyId: String? = nil) -> WebAPI {
        let preferenceId: String? = card.preferenceId == nil ? nil : String(card.preferenceId!)
        let sectionId: String? = card.sectionId == nil ? nil : String(card.sectionId!)
        return WebAPI.cardActionLog(action: rawValue,
                                    cardId: card.cardId,
                                    sectionId: sectionId,
                                    contentId: card.contentId,
                                    preferenceId: preferenceId,
                                    toUserId: toUserId,
                                    activityId: activityId,
                                    storyId: storyId)
    }
    
    private func makeActionLogWebApi(cardId: String,
                                     toUserId: String? = nil,
                                     activityId: String? = nil,
                                     storyId: String? = nil) -> WebAPI {
        return WebAPI.cardActionLog(action: rawValue,
                                    cardId: cardId,
                                    sectionId: nil,
                                    contentId: nil,
                                    preferenceId: nil,
                                    toUserId: toUserId,
                                    activityId: activityId,
                                    storyId: storyId)
        
    }
    
    
    func actionLog(card: CardResponse? = nil,
                   cardId: String? = nil,
                   toUserId: String? = nil,
                   activityId: String? = nil,
                   storyId: String? = nil,
                   completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let actionApi: WebAPI
        if let card = card {
            actionApi = makeActionLogWebApi(card: card, toUserId: toUserId, activityId: activityId, storyId: storyId)
        } else if let cardId = cardId {
            actionApi = makeActionLogWebApi(cardId: cardId, toUserId: toUserId, activityId: activityId, storyId: storyId)
        } else {
            return
        }
        web.request(actionApi) { (result) in
            switch result {
            case .success:
                completion?(true)
            case .failure:
                completion?(false)
            }
        }
        
        if self == .shareWeixin {
            web.request(.interfaceCallLog(type: 1)) { (_) in }
        } else if self == .shareQQ {
            web.request(.interfaceCallLog(type: 3)) { (_) in }
        } else if self == .shareQZ {
            web.request(.interfaceCallLog(type: 4)) { (_) in }
        } else if self == .shareWeibo {
            web.request(.interfaceCallLog(type: 2)) { (_) in }
        }
    }
}


