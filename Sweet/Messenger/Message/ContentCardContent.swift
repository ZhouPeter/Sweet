//
//  ContentCardContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContentCardContent: MessageContent {
    let identifier: String
    let cardType: InstantMessage.CardType
    let text: String
    let imageURLString: String
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case cardType = "type"
        case text = "text"
        case imageURLString = "image_url"
        case url = "url"
    }
}
