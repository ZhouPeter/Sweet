//
//  MessageContent+GetContent.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/11.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class MessageContentHelper {
    
    class func getContentCardContent(resultCard: CardResponse, completion: @escaping (MessageContent?) -> Void) {
        var text = ""
        if let content = resultCard.content, let result = try? content.htmlStringReplaceTag() {
            text = result
        }
        if resultCard.cardEnumType == .content || resultCard.cardEnumType == .groupChat {
            if let videoUrl = resultCard.video {
                MessageContentHelper.makeUploadFirstVideoImage(videoUrl: videoUrl) { (imageUrl) in
                    guard let imageUrl = imageUrl else {
                        completion(nil)
                        return
                    }
                    let content = ContentCardContent(
                        identifier: resultCard.cardId,
                        cardType: InstantMessage.CardType.content,
                        text: text,
                        imageURLString: imageUrl,
                        url: resultCard.url!
                    )
                    completion(content)
                }
            } else if let imageURL = resultCard.imageList?.first {
                let content = ContentCardContent(
                    identifier: resultCard.cardId,
                    cardType: InstantMessage.CardType.content,
                    text: text,
                    imageURLString: imageURL,
                    url: resultCard.url!
                )
                completion(content)
            } else if let thumbnailUrl = resultCard.thumbnail {
                 let content = ArticleMessageContent(
                    identifier: resultCard.cardId,
                    thumbnailURL: thumbnailUrl,
                    title: resultCard.title!,
                    content: String(text.prefix(200)),
                    articleURL: resultCard.url!,
                    source: SourceType(rawValue: resultCard.sourceType)?.getSourceText()
                )
                completion(content)
            } else {
                completion(nil)
            }
        } else if resultCard.cardEnumType == .choice {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(
                identifier: resultCard.cardId,
                cardType: InstantMessage.CardType.preference,
                text: text,
                leftImageURLString: resultCard.imageList![0],
                rightImageURLString: resultCard.imageList![1],
                result: OptionCardContent.Result(rawValue: result)!
            )
            completion(content)
        } else if resultCard.cardEnumType == .evaluation {
            let result = resultCard.result == nil ? -1 : resultCard.result!.index!
            let content = OptionCardContent(
                identifier: resultCard.cardId,
                cardType: InstantMessage.CardType.evaluation,
                text: text,
                leftImageURLString: resultCard.imageList![0],
                rightImageURLString: resultCard.imageList![1],
                result: OptionCardContent.Result(rawValue: result)!
            )
            completion(content)
        } else {
            completion(nil)
        }
    }
    
    class func makeUploadFirstVideoImage(videoUrl: String, completion: @escaping (String?) -> Void) {
        let asset = AVURLAsset(url: URL(string: videoUrl)!)
        let assetGen =  AVAssetImageGenerator(asset: asset)
        assetGen.appliesPreferredTrackTransform = true
        let time = CMTimeMakeWithSeconds(0.0, 600)
        var actualTime = CMTimeMake(0,0)
        do {
            let imageRef = try assetGen.copyCGImage(at: time, actualTime: &actualTime)
            let image = UIImage(cgImage: imageRef)
            guard let fileURL = image.writeToCache(withAlpha: false) else {
                completion(nil)
                return
            }
            Upload.uploadFileToQiniu(localURL: fileURL, type: .imImage) { (token, error) in
                guard let token = token else {
                    logger.debug("upload failed \(error?.localizedDescription ?? "")")
                    return
                }
                completion(token.urlString)
            }
        } catch {
            logger.error(error)
            completion(nil)
        }
    }
    
    
}
