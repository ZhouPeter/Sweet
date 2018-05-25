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
    case poke
}

struct StoryListResponse: Codable {
    let list: [StoryResponse]
}

struct StoryResponse: Codable {
    let avatar: String
    let college: String
    let content: String
    let created: Int
    let enrollment: String
    let like: Bool
    let nickname: String
    let read: Bool
    let storyId: UInt64
    let tag: String
    let type: StoryType
    let university: String
    let userId: UInt64
}
