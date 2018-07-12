//
//  ImageMessageContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/12.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ImageMessageContent: MessageContent {
    let url: String
    
    enum CodingKeys: String, CodingKey {
        case url = "image_url"
    }
}
