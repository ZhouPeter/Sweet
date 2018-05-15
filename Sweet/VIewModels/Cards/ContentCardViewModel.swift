//
//  NewsCardCollectionCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContentCardViewModel {
    let titleString: String
    let contentString: String
    var imageURL: URL?
    let cardId: String
    init(model: CardResponse) {
        self.titleString = "大家都在看"
        self.contentString = model.content!
        if let image = model.imageList {
            self.imageURL = URL(string: image[0])!
        }
        self.cardId = model.cardId
    }
}
