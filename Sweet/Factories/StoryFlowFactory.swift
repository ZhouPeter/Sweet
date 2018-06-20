//
//  StoryFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryFlowFactory {
    func makeStoryRecordView(user: User) -> StoryRecordView
    func makeDismissableStoryRecordView(user: User, topic: String?) -> StoryRecordView
    func makeStoryEditView(fileURL: URL, isPhoto: Bool, topic: String?) -> StoryEditView
    func makeTopicListView() -> TopicListView
    func makeStoryTextView(with topic: String?) -> StoryTextView
    func makeAlbumView() -> AlbumView
    func makePhotoCropView(with photo: UIImage) -> PhotoCropView
}
