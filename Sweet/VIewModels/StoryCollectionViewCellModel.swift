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
    let sourceUserId: Int
    var created: Int?
    let storyId: UInt64
    let type: StoryType
    var pokeCenter: CGPoint = CGPoint(x: 0.5, y: 0.5)
    init(model: StoryResponse) {
        name = model.nickname
        info  = "\(model.university)\n\(model.college)\n\(model.enrollment)"
        avatarImageURL = URL(string: model.avatar)
        if model.type == .image {
            imageURL = URL(string: model.content)
        } else {
            videoURL = URL(string: model.content)
        }
        isRead = model.read
        timestampString = TimerHelper.timeBeforeInfo(timeInterval: TimeInterval(model.created))
        created = model.created
        sourceUserId = Int(model.userId)
        storyId = model.storyId
        type = model.type
    }
}
