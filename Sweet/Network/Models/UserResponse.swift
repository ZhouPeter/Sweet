//
//  UserResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct UserResponse: Codable {
    let userId: UInt64
    let nickname: String
    let avatar: String
    let collegeName: String
    let enrollment: Int
    let gender: Gender
    let phone: String
    let signature: String
    let universityName: String
    let likeCount: Int
    let subscription: Bool
}
