//
//  UserCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct UserCardViewModel {
    var preferenceImageURL: URL?
    var activityId: String?
    var preferenceId: UInt64?
    var storyViewModels: [StoryCellViewModel]?
    let avatarURL: URL
    let nicknameString: String
    let unviersityString: String
    let commonContactString: String
    let commentString: String
    let type: UserContentType
    let userId: UInt64
    var like: Bool
    var showProfile: ((UInt64, SetTop?) -> Void)?
    var callBack: ((String) -> Void)?
    init(model: UserContent) {
        self.userId = model.userId
        self.type = model.type
        self.avatarURL = URL(string: model.avatar)!
        self.nicknameString = model.nickname
        self.unviersityString = model.university
        self.commonContactString = model.info
        self.commentString = model.comment
        self.like = model.like
        if type == .preference {
            self.activityId = model.activityId
            self.preferenceId = model.preferenceId
            self.preferenceImageURL = URL(string: model.preferenceImage!)
        } else {
            storyViewModels = model.storyList?.compactMap { return StoryCellViewModel(model: $0) }
        }
    }
}
