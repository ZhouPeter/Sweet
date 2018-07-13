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
        if resultCard.cardEnumType == .content {
            let url: String
            if let videoUrl = resultCard.video {
                url = videoUrl + "?vframe/jpg/offset/0.0/w/375/h/667"
            } else if let imageURL = resultCard.contentImages?.first?.first?.url {
                url = imageURL
            } else {
                return nil
            }
            let content = ContentCardContent(identifier: resultCard.cardId,
                                             cardType: InstantMessage.CardType.content,
                                             text: resultCard.content!,
                                             imageURLString: url,
                                             url: resultCard.url!)
            return content
        } else if resultCard.cardEnumType == .choice {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(identifier: resultCard.cardId,
                                            cardType: InstantMessage.CardType.preference,
                                            text: resultCard.content!,
                                            leftImageURLString: resultCard.imageList![0],
                                            rightImageURLString: resultCard.imageList![1],
                                            result: OptionCardContent.Result(rawValue: result)!)
            return content
        } else if resultCard.cardEnumType == .evaluation {
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
