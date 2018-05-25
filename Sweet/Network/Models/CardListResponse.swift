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
    let activityList: [ActivityResponse]?
    let defaultEmojiList: [EmojiType]?
    let content: String?
    let imageList: [String]?
    let contentImageList: [ContentImage]?
    let video: String?
    let storyList: [[StoryResponse]]?
    let result: SelectResult?
    let type: CardType
    let name: String?
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

struct ActivityResponse: Codable {
    let avatar: String
    let content: String
    let activityItemId: String
    let like: Bool
    let same: Bool
    let actor: UInt64
    let subtitle: String
    let title: String
}

struct SelectResult: Codable {
    let contactUserList: [UserAvatar]
    let index: Int
    let percent: Double
    
    struct UserAvatar: Codable {
        let avatar: String
        let userId: UInt64
    }
}
