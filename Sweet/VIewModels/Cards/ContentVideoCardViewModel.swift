//
//  ContentVideoCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContentVideoCardViewModel {
    let titleString: String
    let contentString: String
    var videoURL: URL
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    var resultComment: String?
    let defaultImageNameList: [String]
    var emojiDisplayType: EmojiViewDisplay = .default
    init(model: CardResponse) {
        titleString = model.name!
        contentString = model.content!
        cardId = model.cardId
        videoURL = URL(string: model.video!)!
        if let comment = model.result?.comment, comment != "" {
            resultComment = comment
        } else if let emoji = model.result?.emoji, emoji != 0 {
            resultImageName = "ResultEmoji\(emoji)"
            resultAvatarURLs = model.result?.contactUserList.compactMap({ URL(string: $0.avatar) })
            resultUseIDs =  model.result?.contactUserList.compactMap({ $0.userId })
        }
        defaultImageNameList = model.defaultEmojiList!.map { "Emoji\($0.rawValue)"}
    }
}
