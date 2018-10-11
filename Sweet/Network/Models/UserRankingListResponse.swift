//
//  UserRankingListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct UserRankingListResponse: Codable {
    let list: [UserRankingResponse]
}


struct UserRankingResponse: Codable {
    let avatar: String
    let userId: UInt64
    
    init(avatar: String, userId: UInt64) {
        self.avatar = avatar
        self.userId = userId
    }
}
