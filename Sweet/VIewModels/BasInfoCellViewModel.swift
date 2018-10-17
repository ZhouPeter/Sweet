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
    let nicknameString: String
    let constellationString: String
    let collegeInfoString: String
    let starString: String
    let relevantString: String
    let signatureString: String
    let cellHeight: CGFloat
    let sexImage: UIImage
    let rankString: String
    let isLoginUser: Bool
    init(user: UserResponse) {
        userId = user.userId
        avatarImageURL = URL(string: user.avatar)!
        nicknameString = user.nickname
        constellationString = user.zodiac ??  ""
        sexImage = user.gender == .male ? #imageLiteral(resourceName: "Man") : #imageLiteral(resourceName: "Woman")
        let userID = UInt64(Defaults[.userID] ?? "0")
        starString = "\(user.likeCount)"
        relevantString =  "共同联系人\(user.common)人·访问我的主页\(user.visitNum)次·给我点赞\(user.likeNum)次"
        collegeInfoString = user.universityName +
                            (user.collegeName == "" ? "" : ("·" + user.collegeName)) +
                            (user.enrollment <= 0 ? "" : ("·" + "\(user.enrollment)级"))
        signatureString = user.signature == "" ? "暂时没有签名" : "\(user.signature)"
        isLoginUser = userID == user.userId
        rankString = user.rank == 0 ? "" : "学校排行\(user.rank)"
//        rankString = "学校排行100"
        cellHeight = 200 + (isLoginUser ? 0 : 40)
    }
}
