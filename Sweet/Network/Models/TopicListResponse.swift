//
//  TopicListResponse.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct Topic: Codable {
    let ID: UInt64
    let content: String
    
    enum CodingKeys: String, CodingKey {
        case ID = "tagId"
        case content = "tag"
    }
}

struct TopicListResponse: Codable {
    let list: [Topic]
}
