//
//  EvaluationCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct EvaluationCardViewModel {
    let cardId: String
    let titleString: String
    let contentString: String
    let imageURL: [URL]
    var selectedIndex: Int?
    init(model: CardResponse) {
        self.cardId = model.cardId
        self.titleString = model.name!
        self.contentString = model.content!
        self.imageURL = model.imageList!.map({ return URL(string: $0)!})
        if let result = model.result {
            self.selectedIndex = result.index
        }
    }
}
