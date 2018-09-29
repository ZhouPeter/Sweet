//
//  LongTextCardViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation


struct LongTextCardViewModel {
    let titleString: String
    let contentTextAttributed: NSAttributedString?
    let sourceHeight: CGFloat
    let cardId: String
    var resultImageName: String?
    var resultAvatarURLs: [URL]?
    var resultUseIDs: [UInt64]?
    let defaultImageNameList: [String]
    let defaultEmojiList: [Int]
    var emojiDisplayType: EmojiViewDisplay = .show
    let contentId: String?
    let groupId: UInt64?
    let join: Bool?
    let thumbnailURL: URL?
    let sourceTextAttributed: NSAttributedString?
    let sourceText: String?
    let type: CardResponse.CardType
    let joinGroupButtonString: String?
    init(model: CardResponse) {
        titleString = model.name!
        let attributedText = model.content?.getHtmlAttributedString(font: UIFont.systemFont(ofSize: 16),
                                                                    textColor: .black,
                                                                    lineSpacing: 5)
        contentTextAttributed = attributedText
        
        let rect = model.title?.boundingSize(font: UIFont.boldSystemFont(ofSize: 18),
                                             size: CGSize(width: UIScreen.mainWidth() - 40 - 8 * 2,
                                                          height: CGFloat.greatestFiniteMagnitude),
                                             lineSpacing: 5)
        sourceHeight = ceil(rect?.height ?? 0) +
                            (UIScreen.mainWidth() - 40) * 0.4 + 5 + 8 +
                            UIFont.systemFont(ofSize: 12).pointSize
        cardId = model.cardId
        contentId = model.contentId
        groupId = model.groupId
        join = model.join
        if let emoji = model.result?.emoji, emoji != 0 {
            resultImageName = "ResultEmoji\(emoji)"
            resultAvatarURLs = model.result?.contactUserList.compactMap({ URL(string: $0.avatar) })
            resultUseIDs =  model.result?.contactUserList.compactMap({ $0.userId })
        }
        defaultImageNameList = model.defaultEmojiList!.map { "Emoji\($0.rawValue)"}
        defaultEmojiList = model.defaultEmojiList!.map { Int($0.rawValue) }
        thumbnailURL = URL(string: model.thumbnail ?? "")
        sourceTextAttributed = model.title?.getAttributedString(lineSpacing: 5)
        sourceText = model.sourceEnumType?.getSourceText()
        type = model.cardEnumType
        joinGroupButtonString = "点此进入群聊" + (model.topic == nil ? "": " #\(model.topic!)# ") + "🍉"
        
    }
}
