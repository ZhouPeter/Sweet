//
//  MessageContent+GetContent.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class MessageContentHelper {
    
    class func getContentCardContent(resultCard: CardResponse) -> MessageContent? {
        var text = ""
        if let content = resultCard.content, let result = try? content.htmlStringReplaceTag() {
            text = result
        }
        if resultCard.cardEnumType == .content {
            if let videoUrl = resultCard.video {
                return ContentCardContent(
                    identifier: resultCard.cardId,
                    cardType: InstantMessage.CardType.content,
                    text: text,
                    imageURLString: videoUrl + "?vframe/jpg/offset/0.0/w/375/h/667",
                    url: resultCard.url!
                )
            } else if let imageURL = resultCard.contentImages?.first?.first?.url {
                return ContentCardContent(
                    identifier: resultCard.cardId,
                    cardType: InstantMessage.CardType.content,
                    text: text,
                    imageURLString: imageURL,
                    url: resultCard.url!
                )
            } else if let thumbnailUrl = resultCard.thumbnail {
                return ArticleMessageContent(
                    identifier: resultCard.cardId,
                    thumbnailURL: thumbnailUrl,
                    title: resultCard.title!,
                    content: String(text.prefix(200)),
                    articleURL: resultCard.url!
                )
            }
        } else if resultCard.cardEnumType == .choice {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            return OptionCardContent(
                identifier: resultCard.cardId,
                cardType: InstantMessage.CardType.preference,
                text: text,
                leftImageURLString: resultCard.imageList![0],
                rightImageURLString: resultCard.imageList![1],
                result: OptionCardContent.Result(rawValue: result)!
            )
        } else if resultCard.cardEnumType == .evaluation {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            return OptionCardContent(
                identifier: resultCard.cardId,
                cardType: InstantMessage.CardType.evaluation,
                text: text,
                leftImageURLString: resultCard.imageList![0],
                rightImageURLString: resultCard.imageList![1],
                result: OptionCardContent.Result(rawValue: result)!
            )
        }
        return nil
    }
}
