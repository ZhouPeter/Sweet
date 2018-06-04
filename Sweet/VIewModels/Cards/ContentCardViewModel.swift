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
    var resultComment: String?
    let defaultImageNameList: [String]
    init(model: CardResponse) {
        self.titleString = model.name!
        self.contentString = model.content!
        if let imageList = model.contentImageList {
            contentImages = imageList.map { return ContentImageModel(model: $0) }
        } else if let video = model.video {
            self.videoURL = URL(string: video)!
        }
        self.cardId = model.cardId
        if let comment = model.result?.comment, comment != "" {
            self.resultComment = comment
        } else if let emoji = model.result?.emoji, emoji != 0 {
            self.resultImageName = "ResultEmoji\(emoji)"
            if let users = model.result?.contactUserList {
                var urls = [URL]()
                users.forEach { (user) in
                    urls.append(URL(string: user.avatar)!)
                }
                resultAvatarURLs = urls
            }
        }
        self.defaultImageNameList = model.defaultEmojiList!.map { return "Emoji\($0.rawValue)"}
    }
}
struct ContentImageModel {
    let size: CGSize
    let imageURL: URL
    init(model: ContentImage) {
        let scale = (UIScreen.mainWidth() - 20) / 27
        let width = scale * CGFloat(model.width)
        let height = scale * CGFloat(model.height)
        self.size = CGSize(width: width, height: height)
        self.imageURL = URL(string: model.url)!
    }
}
