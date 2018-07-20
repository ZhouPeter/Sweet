//
//  StoryFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum StoryMediaSource {
    case shoot
    case album
}

protocol StoryFlowFactory {
    func makeStoryRecordView(user: User) -> StoryRecordView
    func makeDismissableStoryRecordView(user: User, topic: String?) -> StoryRecordView
    func makeStoryEditView(
        user: User,
        fileURL: URL,
        isPhoto: Bool,
        source: StoryMediaSource,
        topic: String?) -> StoryEditView
    func makeTopicListView() -> TopicListView
    func makeStoryTextView(with topic: String?, user: User) -> StoryTextView
    func makeAlbumView() -> AlbumView
    func makePhotoCropView(with photo: UIImage) -> PhotoCropView
}
