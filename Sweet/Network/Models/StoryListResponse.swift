//
//  StoryListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum StoryType: UInt, Codable {
    case unknown
    case image
    case video
    case text
}

struct StoryListResponse: Codable {
    let list: [StoryResponse]
}

struct StoryResponse: Codable {
    let avatar: String
    let content: String
    let created: Int
    let like: Bool
    let read: Bool
    let storyId: UInt64
    let subtitle: String
    let tag: String
    let title: String
    let type: StoryType
    let userId: UInt64
}
