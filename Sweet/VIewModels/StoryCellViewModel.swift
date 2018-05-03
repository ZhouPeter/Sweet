//
//  StoryCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/27.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryCellViewModel {
    var imageURL: URL?
    var videoURL: URL?
    var read: Bool
    let created: Int
    let storyId: UInt64
    init(model: StoryResponse) {
        if model.type == .video {
            videoURL = URL(string: model.content)
        } else {
            imageURL = URL(string: model.content)
        }
        read = model.read
        created = model.created
        storyId = model.storyId
    }
    init(videoURL: URL) {
        self.videoURL = videoURL
        read = false
        created = 1
        storyId = 1
    }
}
