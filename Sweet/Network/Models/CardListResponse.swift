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

struct CardListResponse: Codable {
    let list: [CardResponse]
}

struct CardResponse: Codable {
    let cardId: String
    let sectionId: UInt64?
    var activityList: [ActivityResponse]?
    let defaultEmojiList: [EmojiType]?
    let content: String?
    let imageList: [String]?
    let contentImageList: [ContentImage]?
    let video: String?
    var storyList: [[StoryResponse]]?
    var result: SelectResult?
    let type: CardType
    let name: String?
    let url: String?
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
    let width: Double
    let height: Double
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
    let comment: String?
    let emoji: Int?
    struct UserAvatar: Codable {
        let avatar: String
        let userId: UInt64
    }
}
