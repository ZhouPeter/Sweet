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
    let activityList: [ActivityResponse]?
    let content: String?
    let imageList: [String]?
    let storyList: [[StoryResponse]]?
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
