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
    let tag: String
    var imageURL: URL?
    var videoURL: URL?
    var read: Bool
    var like: Bool
    let created: Int
    let storyId: UInt64
    let subtitle: String
    let userId: UInt64
    let type: StoryType
    var pokeCenter: CGPoint = CGPoint(x: 0, y: 0)
    var touchArea: CGRect?
    var visualText: String = ""
    var uvNum: UInt
    var timestampString: String
    init(model: StoryResponse) {
        avatarURL = URL(string: model.avatar)!
        nickname = model.nickname
        tag = model.tag
        type = model.type
        if model.type == .video || model.type == .poke {
            videoURL = URL(string: model.content)
            if model.type == .poke {
                pokeCenter = CGPoint(x: min(max(model.centerX ?? 0, -0.5), 0.5),
                                     y: min(max(model.centerY ?? 0, -0.5), 0.5))
            }
        } else {
            imageURL = URL(string: model.content)
        }
        if let touchArea = model.touchArea {
            let touchArea = CGRect(origin: CGPoint(x: UIScreen.mainWidth() * touchArea.originX,
                                                   y: UIScreen.mainHeight() * touchArea.originY),
                                   size: CGSize(width: UIScreen.mainWidth() * touchArea.width,
                                                height: UIScreen.mainHeight() * touchArea.height))
            self.touchArea = touchArea
        }
        read = model.read
        like = model.like
        created = model.created
        storyId = model.storyId
        userId = model.userId
        let storyTime = TimerHelper.storyTime(timeInterval: TimeInterval(model.created))
        subtitle = storyTime.day + storyTime.time
        uvNum = model.uvNum
        timestampString = ""
    }
}
