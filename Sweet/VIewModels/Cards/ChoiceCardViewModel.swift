//
//  ChoiceCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ChoiceCardViewModel {
    let titleString: String
    let contentString: String
    let imageURL: [URL]
    var selectedIndex: Int?
    var percent: Double?
    var avatarURLs: [URL]?
    var userIDs: [UInt64]?
    let cardId: String
    let preferenceId: UInt64?
    init(model: CardResponse) {
        self.cardId = model.cardId
        self.preferenceId = model.preferenceId
        self.titleString = model.name!
        self.contentString = model.content!
        self.imageURL = model.imageList!.map({ (url) -> URL in
            return URL(string: url)!
        })
        if let result = model.result {
            self.selectedIndex = result.index
            self.percent = result.percent
            self.avatarURLs = result.contactUserList.compactMap({ URL(string: $0.avatar)})
            self.userIDs = result.contactUserList.compactMap({ $0.userId })
            if self.avatarURLs!.count > 3 {
                self.avatarURLs?.removeSubrange(3..<result.contactUserList.count)
                self.userIDs?.removeSubrange(3..<result.contactUserList.count)
            }
        }
    }
    
}
