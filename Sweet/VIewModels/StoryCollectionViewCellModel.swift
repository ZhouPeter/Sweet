//
//  FeedsStoryCollectionViewCellModel.swift
//  XPro
//
//  Created by Mario Z. on 2018/3/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryCollectionViewCellModel {
    let name: String
    let avatarImageURL: URL?
    var imageURL: URL?
    var videoURL: URL?
    let isRead: Bool
    let timestampString: String
    let sourceUserId: Int
    var created: Int?
    let storyId: UInt64
    
    init(model: StoryResponse) {
        name = model.nickname
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
    }
}
