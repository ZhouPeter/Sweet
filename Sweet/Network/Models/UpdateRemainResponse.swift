//
//  UpdateRemainResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/7/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct UpdateRemainResponse: Codable {
    var avatar: Int
    var nickname: Int
    var gender: Int
    var university: Int
    var college: Int
    var signature: Int
    var enrollment: Int

    enum CodingKeys: String, CodingKey  {
        case avatar = "2"
        case nickname = "3"
        case gender = "4"
        case university = "5"
        case college = "6"
        case signature = "7"
        case enrollment = "8"
    }
}
