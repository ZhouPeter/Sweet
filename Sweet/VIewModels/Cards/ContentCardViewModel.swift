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
    let contentTextAttributed: NSAttributedString?
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
    let thumbnailURL: URL?
    let sourceTitle: String?
    let sourceBrief: String?
    init(model: CardResponse) {
        titleString = model.name!
        let attributedText = model.content?.getHtmlAttributedString(font: UIFont.systemFont(ofSize: 18),
                                                                    textColor: .black)
        let rect = attributedText?.boundingRect(
            with: CGSize(width: UIScreen.mainWidth() - 40, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        contentHeight = ceil(rect?.height ?? 0) + 1
        contentTextAttributed = attributedText
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
        thumbnailURL = URL(string: model.thumbnail ?? "")
        sourceTitle = model.title
        sourceBrief = model.brief
    }
}
