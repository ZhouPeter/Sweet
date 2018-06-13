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
    var contentImages: [ContentImageModel]?
    var videoURL: URL?
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    var resultComment: String?
    let defaultImageNameList: [String]
    
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
        let scale = (UIScreen.mainWidth() - 20) / 27
        let width = scale * CGFloat(model.width)
        let height = scale * CGFloat(model.height)
        size = CGSize(width: width, height: height)
        imageURL = URL(string: model.url)!
    }
}
