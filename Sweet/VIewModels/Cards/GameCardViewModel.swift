//
//  GameCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct GameCardViewModel {
    let titleString: String
    var resultTitleString: String
    let likeString: String
    var isHiddenLikeCount: Bool
    var isHiddenInfo: Bool
    var timeString: String
    var isShowCompleteInfo: Bool
    let avatarURL: URL
    let simpleInfoString: String
    let completeInfoString: String
    let commentString: String
    var isBigButton: Bool
    var buttonTitleString: String
    let heOrSheString: String
    let userId: UInt64
    let cardId: String
    init(model: CardResponse) {
        cardId = model.cardId
        titleString = model.name!
        let info = model.stealLikeInfo!
        likeString = "当前(\(info.likeCount + 1)-1)"
        timeString = "--:--"
        isShowCompleteInfo = info.stolen
        isHiddenInfo = !info.stolen
        isHiddenLikeCount = info.stolen
        avatarURL = URL(string: info.avatar)!
        if info.gender == .male {
            heOrSheString = "他"
            simpleInfoString = "男生·\(info.city.prefix(info.city.count - 1))某大学"
            completeInfoString = "\(info.name)·\(info.universityName)"
            
        } else {
            heOrSheString = "她"
            simpleInfoString = "女生·\(info.city.prefix(info.city.count - 1))某大学"
            completeInfoString = "\(info.name)·\(info.universityName)"
        }
        resultTitleString = info.stolen ? "从\(heOrSheString)偷❤️成功\n👇👇👇" : "刚刚你被某人偷❤️×1"
        commentString = info.info
        isBigButton = false
        buttonTitleString =  info.stolen ? "访问主页" : "偷回去"
        userId = info.userId
    }
    
}
