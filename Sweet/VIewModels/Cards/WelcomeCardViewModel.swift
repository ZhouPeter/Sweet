//
//  WelcomeCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct WelcomeCardViewModel {
    let cardId: String
    let titleString: String = "欢迎来到讲真app"
    let avatarURL: URL
    let nicknameString: String
    var nameString: String {
        get {
            return self.nicknameString + "\n" + "在这你会遇见："
        }
    }
    let contentStrings: [String] = ["🙈有趣的资讯👽", "🍉有趣的生活🦋", "🙋有趣的同学🙋‍♂️"]
    let bottomString: String =
"""
上划卡片，开启讲真之旅
👆   👆   👆
"""
    
    init(model: CardResponse, user: User) {
        cardId = model.cardId
        avatarURL = URL(string: user.avatar)!
        nicknameString = user.nickname
    }
    
}
