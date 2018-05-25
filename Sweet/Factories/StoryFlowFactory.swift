//
//  StoryFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryFlowFactory {
    func makeStoryRecordView() -> StoryRecordView
    func makeStoryEditView(fileURL: URL, isPhoto: Bool, topic: String?) -> StoryEditView
    func makeTopicListView() -> TopicListView
    func makeStoryTextView() -> StoryTextView
    func makeAlbumView() -> AlbumView
    func makePhotoCropView(with photo: UIImage) -> PhotoCropView
}
