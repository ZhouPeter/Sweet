//
//  StoryCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import CoreGraphics

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
    var pokeCenter = CGPoint.zero
    var touchPath: CGPath?
    var visualText = ""
    var timestampString = ""
    let descString: String?
    let commentString: String?
    let urlString: String?
    let fromCardId: String?
    var newReadCount: Int
    init(model: StoryResponse) {
        avatarURL = URL(string: model.avatar)!
        nickname = model.nickname
        tag = model.tag
        read = model.read
        like = model.like
        created = model.created
        storyId = model.storyId
        userId = model.userId
        let storyTime = TimerHelper.storyTime(timeInterval: TimeInterval(model.created))
        subtitle = storyTime.day + storyTime.time
        descString = model.desc
        commentString = model.comment
        urlString = model.url
        fromCardId = model.fromCardId
        type = model.type
        newReadCount = model.newReadCount
        if type == .video || type == .poke {
            videoURL = URL(string: model.content)
            if model.type == .poke, let x = model.centerX, let y = model.centerY {
                let range: ClosedRange<CGFloat> = -0.5...0.5
                pokeCenter = CGPoint(x: x.clamped(to: range), y: y.clamped(to: range))
            }
        } else {
            imageURL = URL(string: model.content)
        }
        if model.touchArea.count > 2 {
            let path = CGMutablePath()
            let ratio: CGFloat = 16.0 / 9.0
            let height = UIScreen.mainWidth() * ratio
            let width = UIScreen.mainWidth()
            let top = UIScreen.safeTopMargin()
            for (index, point) in model.touchArea.enumerated() {
                let point = CGPoint(x: width * point.x, y: height * point.y + top)
                if index == 0 {
                    path.move(to: point)
                } else {
                    path.addLine(to: point)
                }
            }
            path.closeSubpath()
            touchPath = path
        }
    }
}
