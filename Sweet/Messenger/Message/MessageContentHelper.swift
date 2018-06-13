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
        if resultCard.type == .content {
            let url: String
            if let videoUrl = resultCard.video {
                url = videoUrl + "?vframe/jpg/offset/0.0/w/375/h/667"
            } else {
                url = resultCard.contentImageList![0].url
            }
            let content = ContentCardContent(identifier: resultCard.cardId,
                                             cardType: InstantMessage.CardType.content,
                                             text: resultCard.content!,
                                             imageURLString: url,
                                             url: resultCard.url!)
            return content
        } else if resultCard.type == .choice {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(identifier: resultCard.cardId,
                                            cardType: InstantMessage.CardType.preference,
                                            text: resultCard.content!,
                                            leftImageURLString: resultCard.imageList![0],
                                            rightImageURLString: resultCard.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            return content
        } else if resultCard.type == .evaluation {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(identifier: resultCard.cardId,
                                            cardType: InstantMessage.CardType.evaluation,
                                            text: resultCard.content!,
                                            leftImageURLString: resultCard.imageList![0],
                                            rightImageURLString: resultCard.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            return content
        }
        return nil
    }
}
