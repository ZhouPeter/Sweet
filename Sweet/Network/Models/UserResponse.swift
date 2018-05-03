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
}
