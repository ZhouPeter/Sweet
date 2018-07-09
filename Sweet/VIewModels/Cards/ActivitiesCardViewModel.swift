//
//  FeedsCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
struct ActivitiesCardViewModel {
    var cardId: String
    var activityViewModels: [ActivityCardViewModel]
    let cellHeight: CGFloat
    init(model: CardResponse) {
        cardId = model.cardId
        activityViewModels = model.activityList!.map({
            return ActivityCardViewModel(model: $0)
        })
        cellHeight = (cardCellHeight - 70) / CGFloat(activityViewModels.count)
    }
}

struct ActivityViewModel {
    let actor: UInt64
    var activityId: String
    let avatarURL: URL
    var leftAvatarURL: URL?
    var rightAvatarURL: URL?
    let titleString: String
    let subtitleString: String
    let contentString: String
    let commentString: String
    let emojiImage: UIImage?
    var like: Bool
    var isHiddenLikeButton: Bool
    var callBack: ((String) -> Void)?
    var showProfile: ((UInt64, SetTop?) -> Void)?
    let setTop: SetTop?
    let url: String?
    init(model: ActivityResponse, userAvatarURL: URL? = nil) {
        actor = model.actor
        activityId = model.activityId
        avatarURL = URL(string: model.avatar)!
        titleString = model.title
        subtitleString = model.subtitle
        contentString = model.body.content
        commentString = model.body.comment
        if model.body.emoji.rawValue > 0 {
            emojiImage = UIImage(named: "Emoji\(model.body.emoji.rawValue)")
        } else {
            emojiImage = nil
        }
        like = model.like
        isHiddenLikeButton = model.actor == UInt64(Defaults[.userID]!)!
        if let userAvatarURL = userAvatarURL, model.same {
            leftAvatarURL = userAvatarURL
            rightAvatarURL = avatarURL
        }
        setTop = SetTop(contentId: model.contentId, preferenceId: model.preferenceId)
        url = model.url
    }
}

struct ActivityCardViewModel {
    let actor: UInt64
    var activityId: String
    let avatarURL: URL
    var sameAvatarURL: URL?
    let titleString: String
    let subtitleString: String
    let contentString: String
    let commentString: String
    let emojiImage: UIImage?
    var like: Bool
    var isHiddenLikeButton: Bool
    var callBack: ((String) -> Void)?
    var showProfile: ((UInt64, SetTop?) -> Void)?
    let setTop: SetTop?
    let url: String?
    init(model: ActivityResponse, userAvatarURL: URL? = nil) {
        actor = model.actor
        activityId = model.activityId
        avatarURL = URL(string: model.avatar)!
        titleString = model.title
        subtitleString = model.subtitle
        contentString = model.body.content
        commentString = model.body.comment
        if model.body.emoji.rawValue > 0 {
            emojiImage = UIImage(named: "Emoji\(model.body.emoji.rawValue)")
        } else {
            emojiImage = nil
        }
        like = model.like
        isHiddenLikeButton = model.actor == UInt64(Defaults[.userID]!)!
        if let userAvatarURL = userAvatarURL, model.same {
            sameAvatarURL = userAvatarURL
        }
        setTop = SetTop(contentId: model.contentId, preferenceId: model.preferenceId)
        url = model.url
    }
}
