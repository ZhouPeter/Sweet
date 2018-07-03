//
//  NewsCardCollectionCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
enum EmojiViewDisplay{
    case show
    case allShow
}
struct ContentCardViewModel {
    let titleString: String
    let contentString: String
    let contentTextAttributed: NSAttributedString
    var contentImages: [[ContentImage]]?
    var videoURL: URL?
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    var resultComment: String?
    let defaultImageNameList: [String]
    let defaultEmojiList: [Int]
    var emojiDisplayType: EmojiViewDisplay = .show
    let contentId: String?
    init(model: CardResponse) {
        titleString = model.name!
        contentString = model.content!
        contentTextAttributed = contentString.getTextAttributed(lineSpacing: 6)
        if let imageList = model.contentImages {
            contentImages = imageList
        } else if let video = model.video {
            videoURL = URL(string: video)
        }
        cardId = model.cardId
        contentId = model.contentId
        if let comment = model.result?.comment, comment != "" {
            resultComment = comment
        } else if let emoji = model.result?.emoji, emoji != 0 {
            resultImageName = "ResultEmoji\(emoji)"
            resultAvatarURLs = model.result?.contactUserList.compactMap({ URL(string: $0.avatar) })
            resultUseIDs =  model.result?.contactUserList.compactMap({ $0.userId })
        }
        defaultImageNameList = model.defaultEmojiList!.map { "Emoji\($0.rawValue)"}
        defaultEmojiList = model.defaultEmojiList!.map { Int($0.rawValue) }

    }
    
   
}
