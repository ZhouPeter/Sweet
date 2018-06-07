//
//  StoryMessageContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryMessageContent: MessageContent {
    let identifier: UInt64
    let storyType: StoryType
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case storyType =  "type"
        case url = "url"
    }
}

extension StoryMessageContent {
    func thumbnailURL() -> URL? {
        guard storyType != .unknown else { return nil }
        if storyType == .text || storyType == .image {
            return URL(string: url)
        }
        return URL(string: url + "?vframe/jpg/offset/0.5")
    }
}
