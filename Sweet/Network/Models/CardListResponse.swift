//
//  CardListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct CardListResponse: Codable {
    let list: [CardResponse]
}

struct CardResponse: Codable {
    let cardId: String
    let choiceFeedList: [ChoiceFeedResponse]?
    let content: String?
    let imageList: [String]?
    let storyList: [[StoryResponse]]?
    let type: CardType
    
    enum CardType: UInt, Codable {
        case unknown
        case content
        case choice
        case feed
        case story
        case evaluation
    }
}
struct ChoiceFeedResponse: Codable {
    let content: String
    let feedItemId: String
    let like: Bool
    let same: Bool
    let sourceUserId: UInt64
    let subtitle: String
    let title: String
}
