//
//  ActivityListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ActivityListResponse: Codable {
    let list: [ActivityResponse]
}

struct ActivityResponse: Codable {
    let avatar: String
    let body: ContentBody
    let activityId: String
    var like: Bool
    let same: Bool
    let actor: UInt64
    let subtitle: String
    let title: String
    let fromCardId: String
    let preferenceId: UInt64?
    let contentId: String?
    let url: String?
}
