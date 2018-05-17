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
    let storiesCellModel: [StoryCollectionViewCellModel]
    init(model: CardResponse) {
        cardId = model.cardId
        storiesCellModel = model.storyList!.map {
            return StoryCollectionViewCellModel(model: $0[0])
        }
    }
}
