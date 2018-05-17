//
//  StoryCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryCellViewModel {
    let avatarURL: URL
    let nickname: String
    var imageURL: URL?
    var videoURL: URL?
    var read: Bool
    var like: Bool
    let created: Int
    let storyId: UInt64
    let subtitle: String
    let userId: UInt64
    init(model: StoryResponse) {
        avatarURL = URL(string: model.avatar)!
        nickname = model.nickname
        if model.type == .video {
            videoURL = URL(string: model.content)
        } else {
            imageURL = URL(string: model.content)
        }
        read = model.read
        like = model.like
        created = model.created
        storyId = model.storyId
        userId = model.userId
        let storyTime = TimerHelper.storyTime(timeInterval: TimeInterval(model.created))
        subtitle = storyTime.day + storyTime.time
    }
    init(videoURL: URL) {
        avatarURL = URL(string: "http://a.hiphotos.baidu.com/image/pic/item/728da9773912b31b00eab5648a18367adbb4e1fd.jpg")!
        nickname = "王二妮"
        self.videoURL = videoURL
        read = false
        like = true
        created = 1
        storyId = 1
        subtitle = "昨天上午 10:34"
        userId = 12
    }
}
