//
//  TopicListResponse.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct TopicListResponse: Codable {
    let tags: [String]
    
    enum CodingKeys: String, CodingKey {
        case tags = "list"
    }
}
