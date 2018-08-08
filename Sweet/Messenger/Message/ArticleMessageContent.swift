//
//  ArticleMessageContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/27.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation

struct ArticleMessageContent: MessageContent {
    let identifier: String
    let thumbnailURL: String
    let title: String
    let content: String
    let articleURL: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case thumbnailURL = "thumbnail"
        case articleURL = "url"
        case title = "title"
        case content = "text"
    }
}
