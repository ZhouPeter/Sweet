//
//  ContactListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContactListResponse: Codable {
    let list: [Contact]
}

struct Contact: Codable {
    let avatar: String
    let info: String
    let lastTime: Int
    let nickname: String
    let userId: UInt64
}
