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
    var activityViewModels: [ActivityViewModel]
    let cellHeight: CGFloat
    init(model: CardResponse) {
        cardId = model.cardId
        activityViewModels = model.activityList!.map({
            return ActivityViewModel(model: $0)
        })
        cellHeight = (cardCellHeight - 50) / CGFloat(activityViewModels.count)
    }
}

struct ActivityViewModel {
    var activityId: String
    let avatarURL: URL
    let titleString: String
    let subtitleString: String
    let contentString: String
    let commentString: String
    let emojiImage: UIImage?
    var like: Bool
    var isHiddenLikeButton: Bool
    var callBack: ((String) -> Void)?
    init(model: ActivityResponse) {
        activityId = model.activityId
        avatarURL = URL(string: model.avatar)!
        titleString = model.title
        subtitleString = model.subtitle
        contentString = model.body.content
        commentString = model.body.comment
        if model.body.emoji.rawValue > 0 {
            emojiImage = UIImage(named: "Emoji\(model.body.emoji)")
        } else {
            emojiImage = nil
        }
        like = model.like
        isHiddenLikeButton = model.actor == UInt64(Defaults[.userID]!)!
    }
}
