//
//  UserResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct  ProfileResponse: Codable {
    let userProfile: UserResponse
    let setting: UserSetting?
}

struct UserResponse: Codable {
    let userId: UInt64
    var nickname: String
    var avatar: String
    var collegeName: String
    var enrollment: Int
    var gender: Gender
    var phone: String
    var signature: String
    var universityName: String
    let likeCount: Int
    var subscription: Bool
    var blacklist: Bool
    var block: Bool
    let common: Int
    let activityNum: UInt64
    let storyNum: UInt64
    let likeNum: UInt64
    let visitNum: UInt64
    let rank: UInt64
    var zodiac: String?
}

extension User {
    init(_ response: UserResponse) {
        userId = response.userId
        nickname = response.nickname
        avatar = response.avatar
        enrollment = response.enrollment
        gender = response.gender
        phone = response.phone
        signature = response.signature
        collegeName = response.collegeName
        universityName = response.universityName
        isBlacklisted = response.blacklist
    }
}
