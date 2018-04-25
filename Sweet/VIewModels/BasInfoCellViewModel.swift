//
//  BasInfoCellViewModel.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/3/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct BaseInfoCellViewModel {
    let userId: UInt64
    let avatarImageURL: URL
    let nameString: String
    let networkString: String
    let signatureString: String
    let likeCountString: String
    let subscribeButtonString: String
    var subscribeAction: (() -> Void)?
    let cellHeight: CGFloat
    init(user: UserResponse) {
        userId = user.userId
        avatarImageURL = URL(string: user.avatar)!
        nameString = user.nickname
        let sex = user.gender.rawValue == 1 ? "男生" : "女生"
        networkString = sex + "·" + "\(user.enrollment)" + "级\n" +
                        user.universityName + "\n" +
                        user.collegeName
        signatureString = user.signature
        likeCountString = "获\(user.likeCount)♥️"
        subscribeButtonString = user.subscription ? "已订阅" : "订阅"
        cellHeight = 130
    }
}
