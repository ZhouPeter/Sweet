//
//  FeedsCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ActivitiesCardViewModel {
    var activityViewModels: [ActivityViewModel]
    let cellHeight: CGFloat
    init(model: CardResponse) {
        activityViewModels = model.activityList!.map({
            return ActivityViewModel(model: $0)
        })
        cellHeight = cardCellHeight / CGFloat(activityViewModels.count)
    }
}

struct ActivityViewModel {
    let activityItemId: String
    let avatarURL: URL
    let titleString: String
    let subtitleString: String
    let contentString: String
    let like: Bool
    var callBack: ((String) -> Void)?
    init(model: ActivityResponse) {
        activityItemId = model.activityItemId
        avatarURL = URL(string: model.avatar)!
        titleString = model.title
        subtitleString = model.subtitle
        contentString = model.content
        like = model.like
    }
}