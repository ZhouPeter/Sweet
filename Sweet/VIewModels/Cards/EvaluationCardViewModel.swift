//
//  EvaluationCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct EvaluationCardViewModel {
    let titleString: String
    let contentString: String
    let imageURL: [URL]
    var selectedIndex: Int?
    init(model: CardResponse) {
        self.titleString = model.name!
        self.contentString = model.content!
        self.imageURL = model.imageList!.map({ (url) -> URL in
            return URL(string: url)!
        })
        if let result = model.result {
            self.selectedIndex = result.index
        }
    }
}
