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
    let contentHeight: CGFloat
    var contentImages: [[ContentImage]]?
    var imageURLList: [URL]?
    var videoURL: URL?
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    let defaultImageNameList: [String]
    let defaultEmojiList: [Int]
    var emojiDisplayType: EmojiViewDisplay = .show
    let contentId: String?
    init(model: CardResponse) {
        titleString = model.name!
        contentString = model.content! 
        contentHeight = contentString.boundingSize(
            font: UIFont.systemFont(ofSize: 18),
            size:CGSize(width: UIScreen.mainWidth() - 30, height: CGFloat.greatestFiniteMagnitude),
            lineSpacing: 5).height
        contentTextAttributed = contentString.getTextAttributed(lineSpacing: 5)
        if  model.imageList != nil {
            imageURLList = model.imageList?.compactMap { URL(string: $0) }
        } else if let video = model.video {
            videoURL = URL(string: video)
        }

        cardId = model.cardId
        contentId = model.contentId
        if let emoji = model.result?.emoji, emoji != 0 {
            resultImageName = "ResultEmoji\(emoji)"
            resultAvatarURLs = model.result?.contactUserList.compactMap({ URL(string: $0.avatar) })
            resultUseIDs =  model.result?.contactUserList.compactMap({ $0.userId })
        }
        defaultImageNameList = model.defaultEmojiList!.map { "Emoji\($0.rawValue)"}
        defaultEmojiList = model.defaultEmojiList!.map { Int($0.rawValue) }

    }
    
   
}
