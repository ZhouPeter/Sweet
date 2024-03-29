//
//  StoryListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import CoreGraphics

enum StoryType: UInt, Codable {
    case unknown
    case image
    case video
    case text
    case poke
    case share
    
    var isVideoFile: Bool {
        if self == .video || self == .poke {
            return true
        }
        return false
    }
}

struct StoryListResponse: Codable {
    let list: [StoryResponse]
}

struct StoriesGroupResponse: Codable {
    let list: [[StoryResponse]]
}

struct StoryResponse: Codable {
    let avatar: String
    let college: String
    let content: String
    let created: Int
    let enrollment: String
    var like: Bool
    let nickname: String
    let tag: String
    var read: Bool
    let storyId: UInt64
    let type: StoryType
    let university: String
    let userId: UInt64
    let centerX: CGFloat?
    let centerY: CGFloat?
    var touchArea: [TouchPoint]
    let comment: String?
    let desc: String?
    let url: String?
    let fromCardId: String?
    let uvNum: UInt64?
    enum CodingKeys: String, CodingKey {
        case avatar
        case college
        case content
        case created
        case enrollment
        case like
        case nickname
        case tag
        case read
        case storyId
        case type
        case university
        case userId
        case centerX = "x"
        case centerY = "y"
        case touchArea
        case comment
        case desc
        case url
        case fromCardId
        case uvNum
    }
}

struct TouchPoint: Codable {
    let x: CGFloat
    let y: CGFloat
}

struct StoryGetResponse: Codable {
    let story: StoryResponse
}
