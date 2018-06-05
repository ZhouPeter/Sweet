//
//  StoryMessageContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryMessageContent: MessageContent {
    let storyType: StoryType
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case storyType =  "type"
        case url = "url"
    }
}
