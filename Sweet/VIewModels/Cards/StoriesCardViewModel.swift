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
    let storiesCellModels: [[StoryCollectionViewCellModel]]
    let storiesGroup: [[StoryCellViewModel]]
    var isReads: [Bool]
    init(model: CardResponse) {
        cardId = model.cardId
        storiesCellModels = model.storyList!.map {
           return $0.map { return StoryCollectionViewCellModel(model: $0) }
        }
        storiesGroup = model.storyList!.map {
            return $0.map { return StoryCellViewModel(model: $0) }
        }
        isReads = model.storyList!.map({ (model) -> Bool in
            var isRead = true
            model.forEach({ if $0.read == false {isRead = false} })
            return isRead
        })
    }
}
