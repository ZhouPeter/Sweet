//
//  StoryCollectionViewCellModel.swift
//  XPro
//
//  Created by Mario Z. on 2018/3/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryCollectionViewCellModel {
    let name: String
    let info: String
    let avatarImageURL: URL?
    var imageURL: URL?
    var videoURL: URL?
    var isRead: Bool
    let timestampString: String
    let sourceUserId: UInt64
    var created: Int?
    let storyId: UInt64
    let type: StoryType
    var pokeCenter: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var callback: ((UInt64) -> Void)?
    init(model: StoryResponse) {
        name = model.nickname
        info  = "\(model.university)\n\(model.college)\n\(model.enrollment)"
        avatarImageURL = URL(string: model.avatar)
        if model.type == .image || model.type == .text {
            imageURL = URL(string: model.content)
        } else if model.type  == .video || model.type == .poke {
            if model.type == .poke {
                pokeCenter = CGPoint(x: min(max(model.centerX ?? 0, -0.5), 0.5),
                                     y: min(max(model.centerY ?? 0, -0.5), 0.5))
            }
            videoURL = URL(string: model.content)
        }
        isRead = model.read
        timestampString = TimerHelper.timeBeforeInfo(timeInterval: TimeInterval(model.created))
        created = model.created
        sourceUserId = model.userId
        storyId = model.storyId
        type = model.type
    }
}
