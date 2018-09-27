//
//  NotiCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct NotiCardViewModel {
    let cardId: String
    let titleString: String
    var likeRankViewModels: [LikeRankViewModel]
    let changeType: RankChangeType
    var showRankingList: (() -> Void)?
    
    init(model: CardResponse) {
        cardId = model.cardId
        titleString = model.name!
        likeRankViewModels = (model.likeRank?.rankList.compactMap({ return LikeRankViewModel(model: $0) }))!
        if model.likeRank!.rankChangeNum > 0 {
            changeType = .up
        } else if  model.likeRank!.rankChangeNum < 0 {
            changeType = .down
        } else {
            changeType = .none
        }
        
    }
}

enum RankChangeType: UInt {
    case none
    case up
    case down
}

struct LikeRankViewModel {
    let index: UInt64
    let avatarURL: URL
    let nameString: String
    var commentString: String
    let likeCount: UInt64
    let userId: UInt64
    var showProfile: ((UInt64, SetTop?) -> Void)?
    init(model: LikeRankRecord) {
        index = model.index
        avatarURL = URL(string: model.avatar)!
        nameString = model.name
        commentString = model.info
        likeCount = model.likeCount
        userId = model.userId
    }
}
