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
    let sourceUserId: UInt64
    var created: Int?
    let storyId: UInt64
    let type: StoryType
    var pokeCenter: CGPoint = CGPoint(x: 0.5, y: 0.5)
    var callback: ((UInt64) -> Void)?
    var commentString: String?
    init(model: StoryResponse) {
        name = model.nickname
        info  = "\(model.university)\n\(model.college)\n\(model.enrollment)"
        avatarImageURL = URL(string: model.avatar)
        if model.type  == .video || model.type == .poke {
            if model.type == .poke, let x = model.centerX, let y = model.centerY  {
                let range: ClosedRange<CGFloat> = -0.5...0.5
                pokeCenter = CGPoint(x: x.clamped(to: range), y: y.clamped(to: range))
            }
            videoURL = URL(string: model.content)
        } else {
            imageURL = URL(string: model.content)
        }
        isRead = model.read
        created = model.created
        sourceUserId = model.userId
        storyId = model.storyId
        type = model.type
        commentString = model.comment
    }
}
