//
//  UserData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class UserData: Object {
    @objc dynamic var userID: Int64 = 0
    @objc dynamic var avatarURLString: String = ""
    @objc dynamic var nickname: String = ""
    @objc dynamic var phone: String?
    @objc dynamic var university: String?
    @objc dynamic var college: String?
    @objc dynamic var enrollment: Int = 0
    @objc dynamic var gender: Int = 1
    @objc dynamic var signature: String = ""
    @objc dynamic var city: String?
    @objc dynamic var isBlacklisted = false
    @objc dynamic var isBlock = false
    @objc dynamic var isSubscription = false
    @objc dynamic var likeCount = 0
    @objc dynamic var common = 0

    let userType = RealmOptional<Int32>()
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    class func data(with info: SimpleUserInfo) -> UserData {
        let data = UserData()
        data.userID = Int64(info.userID)
        data.avatarURLString = info.avatar
        data.nickname = info.nickname
        data.university = info.universityName
        data.college = info.collegeName
        data.enrollment = Int(info.enrollment)
        data.city = info.city
        data.gender = info.gender.rawValue
        data.userType.value = Int32(info.userType)
        data.isBlacklisted = info.isBlacklisted
        return data
    }
    
    class func data(with response: UserResponse) -> UserData {
        let data = UserData()
        data.userID = Int64(response.userId)
        data.avatarURLString = response.avatar
        data.nickname = response.nickname
        data.university = response.universityName
        data.college = response.collegeName
        data.enrollment = Int(response.enrollment)
        data.signature = response.signature
        data.gender = response.gender.rawValue
        data.likeCount = response.likeCount
        data.isBlacklisted = response.blacklist
        data.isBlock = response.blacklist
        data.isSubscription = response.subscription
        data.common = response.common
        data.phone = response.phone
        return data
    }
    
    class func data(with user: User) -> UserData {
        let data = UserData()
        data.userID = Int64(user.userId)
        data.avatarURLString = user.avatar
        data.nickname = user.nickname
        data.university = user.universityName
        data.college = user.collegeName
        data.enrollment = user.enrollment
        data.gender = user.gender.rawValue
        data.signature = user.signature
        data.city = user.city
        data.userType.value = user.userType
        data.isBlacklisted = user.isBlacklisted ?? false
        data.phone = user.phone
        return data
    }
}

extension User {
    init(data: UserData) {
        userId = UInt64(data.userID)
        nickname = data.nickname
        avatar = data.avatarURLString
        enrollment = data.enrollment
        gender = Gender(rawValue: data.gender) ?? .unknown
        phone = data.phone
        signature = data.signature
        collegeName = data.college
        universityName = data.university
        city = data.city
        userType = data.userType.value
        isBlacklisted = data.isBlacklisted
    }
}

extension UserResponse {
    init(data: UserData) {
        userId = UInt64(data.userID)
        nickname = data.nickname
        avatar = data.avatarURLString
        collegeName = data.college ?? ""
        universityName = data.university ?? ""
        enrollment = data.enrollment
        gender = Gender(rawValue: data.gender) ?? .unknown
        phone = data.phone ?? ""
        signature = data.signature
        likeCount = data.likeCount
        subscription = data.isSubscription
        blacklist = data.isBlacklisted
        block = data.isBlock
        common = data.common
        activityNum = 0
        storyNum = 0
        rank = 0
    }
}
