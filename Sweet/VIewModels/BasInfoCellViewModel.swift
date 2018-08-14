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
    let nicknameSexAttributedString: NSAttributedString
    let collegeInfoString: String
    let starContactString: String
    let signatureString: String
    let isHiddenEdit: Bool
    let cellHeight: CGFloat
    init(user: UserResponse) {
        userId = user.userId
        avatarImageURL = URL(string: user.avatar)!
        let string = "\(user.nickname)" +  (user.gender == .male ? "♂" : "♀")
        let attributedString = NSMutableAttributedString(string: string, attributes: [
            .font: UIFont.boldSystemFont(ofSize: 18),
            .foregroundColor: UIColor.black
            ])
        attributedString.addAttribute(.foregroundColor,
                                    value: user.gender == .male ? UIColor(hex: 0x4A90E2) : UIColor(hex: 0xB761F9),
                                    range: NSRange(location: user.nickname.utf16.count, length: 1))
        nicknameSexAttributedString = attributedString
        let userID = UInt64(Defaults[.userID] ?? "0")
        starContactString = "\(user.likeCount == 0 ? "暂无" : "\(user.likeCount)")获赞"
                            + (user.common == 0 ? "" : "·\(user.common)共同联系人")
        collegeInfoString = user.universityName + "·" + user.collegeName + "·" + "\(user.enrollment)级"
        signatureString = user.signature == "" ? "暂时没有签名" : "「\(user.signature)」"
        isHiddenEdit = userID == user.userId ? user.signature != "" : true
        cellHeight = 244
    }
}
