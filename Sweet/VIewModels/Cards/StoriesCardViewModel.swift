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
    let storiesCellModels: [[StoryCollectionViewCellModel]]
    let storiesGroup: [[StoryCellViewModel]]
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
}
