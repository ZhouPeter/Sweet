//
//  StoryDetailsUvList.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryUvList: Codable {
    let likeCount: Int
    let list: [StoryUvInfo]

}

struct StoryUvInfo: Codable {
    let avatar: String
    let info: String
    let like: Bool
    let nickname: String
    let userId: UInt64
}
