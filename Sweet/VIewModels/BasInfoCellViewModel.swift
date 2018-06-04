//
//  BasInfoCellViewModel.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/3/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
struct BaseInfoCellViewModel {
    let userId: UInt64
    let avatarImageURL: URL
    let nameString: String
    let networkString: String
    let signatureString: String
    let likeCountString: String
    var subscribeButtonString: String
    var subscribeAction: ((UInt64) -> Void)?
    var sendMessageAction: (() -> Void)?
    let cellHeight: CGFloat
    let subscriptionButtonHidden: Bool
    let sendMessageButtonHidden: Bool
    init(user: UserResponse) {
        userId = user.userId
        avatarImageURL = URL(string: user.avatar)!
        nameString = user.nickname
        let sex = user.gender.rawValue == 1 ? "男生" : "女生"
        networkString = sex + "·" + "\(user.enrollment)" + "级\n" +
                        user.universityName + "\n" +
                        user.collegeName
        signatureString = user.signature
        likeCountString = "♥️\(user.likeCount)"
        let userID = UInt64(Defaults[.userID] ?? "0")
        subscriptionButtonHidden = user.userId == userID
        sendMessageButtonHidden = user.userId == userID
        subscribeButtonString = user.subscription ? "已订阅" : "订阅"
        cellHeight = user.userId == userID ? 140 : 180
    }
}
