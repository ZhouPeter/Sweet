//
//  OptionCardContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct OptionCardContent: MessageContent {
    let identifier: String
    let cardType: InstantMessage.CardType
    let text: String
    let leftImageURLString: String
    let rightImageURLString: String
    let result: Result
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case cardType = "type"
        case text = "text"
        case leftImageURLString = "image_url_1"
        case rightImageURLString = "image_url_2"
        case result = "result"
    }
    
    enum Result: Int, Codable {
        case left
        case right
    }
}
