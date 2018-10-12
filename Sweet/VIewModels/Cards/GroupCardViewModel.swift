//
//  GroupCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/12.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct GroupCardViewModel {
    let cardId: String
    let groupId: UInt64
    let titleString: String
    let groupTitle: String
    let avatarURLs: [URL]
    let members: [UInt64]
    let buttonTitleString: String
    var showProfile: ((UInt64) -> Void)?
    let backgroudImageURL: URL?
    init(model: CardResponse) {
        cardId = model.cardId
        groupId = model.groupId!
        titleString = model.name!
        groupTitle = model.content!
        avatarURLs = model.userAvatarList?.compactMap { URL(string: $0.avatar)} ?? [URL]()
        members = model.userAvatarList?.compactMap { $0.userId } ?? [UInt64]()
        buttonTitleString = model.join ?? false ? "回到群聊" : "加入群聊"
        backgroudImageURL = URL(string: model.backgroundImage!)
    }
}
