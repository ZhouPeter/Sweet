//
//  PreferenceTextViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/10/16.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

struct PreferenceTextViewModel {
    let activityId: String
    let cardId: String
    let isSame: Bool
    var isLike: Bool
    let textString: String
    let imageURL: URL
    var isHiddenLikeButton: Bool
    var callBack: ((String) -> Void)?
    init(model: PreferenceTextResponse) {
        self.activityId = model.activityId
        self.cardId = model.cardId
        self.isSame = model.same
        self.isLike = model.like
        self.textString = model.text
        self.imageURL = URL(string: model.image)!
        self.isHiddenLikeButton = model.userId == UInt64(Defaults[.userID]!)!
    }
}
