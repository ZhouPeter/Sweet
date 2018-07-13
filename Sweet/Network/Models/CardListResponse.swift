//
//  CardListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum EmojiType: UInt, Codable {
    case unknown
    case good
    case cry
    case grin
    case yeah
    case happy
    case smile
}
enum SourceType: UInt, Codable {
    case `default`
    case weibo
    case weixin
    case douyin
    case toutiaohao
    case zhihu
    case bilibili
    case xiaohongshu
}
struct CardListResponse: Codable {
    let list: [CardResponse]
}

struct CardResponse: Codable {
    let cardId: String
    let sectionId: UInt64?
    let contentId: String?
    let preferenceId: UInt64?
    var activityList: [ActivityResponse]?
    let defaultEmojiList: [EmojiType]?
    let content: String?
    let imageList: [String]?
    let contentImages: [[ContentImage]]?
    let video: String?
    var storyList: [[StoryResponse]]?
    var result: SelectResult?
    let type: UInt
    var cardEnumType: CardType {
        return CardType(rawValue: type) ?? .unknown
    }
    let name: String?
    let url: String?
    let thumbnail: String?
    let title: String?
    let brief: String?
    let sourceType: UInt
    var sourceEnumType: SourceType? {
        return SourceType(rawValue: sourceType)
    }
    enum CardType: UInt, Codable {
        case unknown
        case content
        case choice
        case activity
        case story
        case evaluation
    }
}

struct ContentImage: Codable {
    let width: CGFloat
    let height: CGFloat
    let url: String
}

struct ContentBody: Codable {
    let content: String
    let comment: String
    let emoji: EmojiType
}

struct SelectResult: Codable {
    let contactUserList: [UserAvatar]
    var index: Int?
    let percent: Double?
    let emoji: Int?
    struct UserAvatar: Codable {
        let avatar: String
        let userId: UInt64
    }
}

struct CardGetResponse: Codable {
    let card: CardResponse
}
