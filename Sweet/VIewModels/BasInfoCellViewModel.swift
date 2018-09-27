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
    let collegeInfoString: String
    let starString: String
    let contactString: String
    let signatureString: String
    let isEditSignature: Bool
    let cellHeight: CGFloat
    let sexImage: UIImage
    init(user: UserResponse) {
        userId = user.userId
        avatarImageURL = URL(string: user.avatar)!
        nicknameString = user.nickname
        sexImage = user.gender == .male ? #imageLiteral(resourceName: "Man") : #imageLiteral(resourceName: "Woman")
        let userID = UInt64(Defaults[.userID] ?? "0")
        starString = "\(user.likeCount)"
        contactString = (user.common == 0 ? "" : " · \(user.common)共同联系人")
        collegeInfoString = user.universityName +
                            (user.collegeName == "" ? "" : ("·" + user.collegeName)) +
                            (user.enrollment <= 0 ? "" : ("·" + "\(user.enrollment)级"))
        signatureString = user.signature == "" ? "暂时没有签名" : "\(user.signature)"
        isEditSignature = userID == user.userId
        cellHeight = 200
    }
}
