//
//  StoriesCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoriesCardViewModel {
    let cardId: String
    var storyCellModels: [StoryCollectionViewCellModel]
    var storiesCellModels: [[StoryCollectionViewCellModel]]
    var storiesGroup: [[StoryCellViewModel]]
    init(model: CardResponse) {
        cardId = model.cardId
        storiesCellModels = model.storyList!.map {
           return $0.map { return StoryCollectionViewCellModel(model: $0) }
        }
        storyCellModels = storiesCellModels.map {
            var storiesCellModel = $0
            var isRead = true
            storiesCellModel.forEach({ if $0.isRead == false {isRead = false} })
            var storyCellModel = storiesCellModel[0]
            storyCellModel.isRead = isRead
            return storyCellModel
        }
        storiesGroup = model.storyList!.map {
            return $0.map { return StoryCellViewModel(model: $0) }
        }
    }
    
    mutating func updateStory(story: StoryCellViewModel, postion: (Int, Int)) {
        storiesGroup[postion.0][postion.1].read = story.read
        storiesCellModels[postion.0][postion.1].isRead = story.read
        storiesGroup[postion.0][postion.1].like = story.like
        var storyCellModels: [StoryCollectionViewCellModel] = storiesCellModels.map {
            var storiesCellModel = $0
            var isRead = true
            storiesCellModel.forEach({ if $0.isRead == false {isRead = false} })
            var storyCellModel = storiesCellModel[0]
            storyCellModel.isRead = isRead
            return storyCellModel
        }
        for index in 0..<storyCellModels.count {
            storyCellModels[index].callback = self.storyCellModels[index].callback
        }
        self.storyCellModels = storyCellModels
    }
}
