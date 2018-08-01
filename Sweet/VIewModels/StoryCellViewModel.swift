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
    var touchPath: CGPath?
    var visualText: String = ""
    var timestampString: String
    let descString: String?
    let commentString: String?
    let urlString: String?
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
        if model.touchArea.count > 2 {
            let path = CGMutablePath()
            for (index, touchPoint) in model.touchArea.enumerated() {
                let height = UIScreen.mainWidth() * 16.0 / 9.0
                let width = UIScreen.mainWidth()
                let point = CGPoint(x: width * touchPoint.originX,
                                    y: height * touchPoint.originY +  UIScreen.safeTopMargin())
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            touchPath = path
        }
        read = model.read
        like = model.like
        created = model.created
        storyId = model.storyId
        userId = model.userId
        let storyTime = TimerHelper.storyTime(timeInterval: TimeInterval(model.created))
        subtitle = storyTime.day + storyTime.time
        timestampString = ""
        descString = model.desc
        commentString = model.comment
        urlString = model.url
    }
}
