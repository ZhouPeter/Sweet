//
//  PreferenceTextListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct PreferenceTextListResponse: Codable {
    let list: [PreferenceTextResponse]
}

struct PreferenceTextResponse: Codable {
    let activityId: String
    let cardId: String
    let image: String
    var like: Bool
    let same: Bool
    let text: String
    let userId: UInt64
}
