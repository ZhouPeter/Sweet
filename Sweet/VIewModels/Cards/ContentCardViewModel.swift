//
//  NewsCardCollectionCellViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
enum EmojiViewDisplay{
    case `default`
    case show
    case allShow
}
struct ContentCardViewModel {
    let titleString: String
    let contentString: String
    var contentImages: [ContentImageModel]?
    var videoURL: URL?
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
        if let imageList = model.contentImageList {
            contentImages = imageList.map { ContentImageModel(model: $0) }
        } else if let video = model.video {
            videoURL = URL(string: video)
        }
        cardId = model.cardId
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

struct ContentImageModel {
    let size: CGSize
    let imageURL: URL
    
    init(model: ContentImage) {
        size = CGSize(width: CGFloat(model.width), height: CGFloat(model.height))
        imageURL = URL(string: model.url)!
    }
}
