//
//  UsersCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct UsersCardViewModel {
    let cardId: String
    var userContents: [UserCardViewModel]
    init(model: CardResponse) {
        self.cardId = model.cardId
        userContents = model.userContentList!.compactMap { return UserCardViewModel(model: $0)}
    }

}
