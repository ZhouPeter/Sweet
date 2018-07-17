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
    let contentHeight: CGFloat
    let contentTextAttributed: NSAttributedString?
    var videoURL: URL
    var videoPicURL: URL?
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    let defaultImageNameList: [String]
    let defaultEmojiList: [Int]
    var emojiDisplayType: EmojiViewDisplay = .show
    let contentId: String?
    var currentTime: TimeInterval = 0.0
    init(model: CardResponse) {
        titleString = model.name!
        let attributedText = model.content?.getHtmlAttributedString(font: UIFont.systemFont(ofSize: 18),
                                                                    textColor: .black,
                                                                    lineSpacing: 5)
        let rect = attributedText?.boundingRect(
            with: CGSize(width: UIScreen.mainWidth() - 40, height: CGFloat.greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil)
        contentHeight = ceil(rect?.height ?? 0) + 1
        contentTextAttributed = attributedText
        cardId = model.cardId
        contentId = model.contentId
        videoURL = URL(string: model.video!)!
        videoPicURL = URL(string: model.videoPic ?? "")
        if let emoji = model.result?.emoji, emoji != 0 {
            resultImageName = "ResultEmoji\(emoji)"
            resultAvatarURLs = model.result?.contactUserList.compactMap({ URL(string: $0.avatar) })
            resultUseIDs =  model.result?.contactUserList.compactMap({ $0.userId })
        }
        defaultImageNameList = model.defaultEmojiList!.map { "Emoji\($0.rawValue)"}
        defaultEmojiList = model.defaultEmojiList!.map { Int($0.rawValue) }
    }
}
