//
//  CardListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

enum EmojiType: UInt, Codable {
    case unknown
    case good
    case cry
    case grin
    case yeah
    case happy
    case smile
}
enum SourceType: UInt, Codable {
    case `default`
    case weibo
    case weixin
    case douyin
    case toutiaohao
    case zhihu
    case bilibili
    case xiaohongshu
    func getSourceText() -> String {
        switch self {
        case .weixin:
            return "weixin.com"
        case .zhihu:
            return "zhihu.com"
        case .toutiaohao:
            return "toutiaohao.com"
        default:
            return ""
        }
    }
}
struct CardListResponse: Codable {
    let list: [CardResponse]
}

struct CardResponse: Codable {
    let cardId: String
    let sectionId: UInt64?
    let contentId: String?
    let preferenceId: UInt64?
    var activityList: [ActivityResponse]?
    let defaultEmojiList: [EmojiType]?
    let content: String?
    let imageList: [String]?
    let contentImages: [[ContentImage]]?
    let video: String?
    let videoPic: String?
    var storyList: [[StoryResponse]]?
    var result: SelectResult?
    let type: UInt
    var cardEnumType: CardType {
        return CardType(rawValue: type) ?? .unknown
    }
    let name: String?
    let url: String?
    let thumbnail: String?
    let title: String?
    let brief: String?
    let sourceType: UInt
    var sourceEnumType: SourceType? {
        return SourceType(rawValue: sourceType)
    }
    enum CardType: UInt, Codable {
        case unknown
        case content
        case choice
        case activity
        case story
        case evaluation
    }
    
    func makeShareText() -> String? {
        let text: String?
        if let url = url {
            if let source = sourceEnumType, source == .douyin {
                text = "我正在看「\(name!)」的抖音视频 \(url)"
            } else {
                text = String.getShareText(content: content, url: url)
            }
        } else {
            text = nil
        }
        return text
    }
    
    func makeStoryDraft() -> StoryDraft? {
        if cardEnumType == .content {
            var text = ""
            if let content = content, let result = try? content.htmlStringReplaceTag().removedURLLinks() {
                text = result
            }
            if let video = video {
                let asset = AVURLAsset(url: URL(string: video)!)
                let assetGen =  AVAssetImageGenerator(asset: asset)
                assetGen.appliesPreferredTrackTransform = true
                let time = CMTimeMakeWithSeconds(0.0, 600)
                var actualTime = CMTimeMake(0,0)
                do {
                    let imageRef = try assetGen.copyCGImage(at: time, actualTime: &actualTime)
                    let text = (try content?.htmlStringReplaceTag()) ?? ""
                    let image = UIImage(cgImage: imageRef).strechedToSize(toSize: CGSize(width: 720, height: 1280))
                    guard let url = image.writeToCache(withAlpha: false) else { return nil }
                    let storyDraft = StoryDraft(filename: url.lastPathComponent,
                                                storyType: .share,
                                                date: Date(),
                                                comment: nil,
                                                desc: String(text.prefix(100)),
                                                url: self.url)
                    return storyDraft
                } catch {
                    logger.error(error)
                    return nil
                }
            } else if let imageList = imageList {
                let imageUrl = imageList[0]
                let cfUrl = URL(string: imageUrl)! as CFURL
                let gifSource  = CGImageSourceCreateWithURL(cfUrl, nil)
                let imageCount = CGImageSourceGetCount(gifSource!) 
                guard imageCount > 0 else { return nil }
                guard let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, 0, nil) else { return nil }
                let image = UIImage(cgImage: imageRef).strechedToSize(toSize: CGSize(width: 720, height: 1280))
                guard let url = image.writeToCache(withAlpha: false) else { return nil }
                let storyDraft = StoryDraft(filename: url.lastPathComponent,
                                            storyType: .share,
                                            date: Date(),
                                            comment: nil,
                                            desc: String(text.prefix(100)),
                                            url: self.url)
                return storyDraft
            } else if let thumbnail = thumbnail {
                let cfUrl = URL(string: thumbnail)! as CFURL
                let gifSource  = CGImageSourceCreateWithURL(cfUrl, nil)
                let imageCount = CGImageSourceGetCount(gifSource!)
                guard imageCount > 0 else { return nil }
                guard let imageRef = CGImageSourceCreateImageAtIndex(gifSource!, 0, nil) else { return nil }
                let image = UIImage(cgImage: imageRef).strechedToSize(toSize: CGSize(width: 720, height: 1280))
                guard let url = image.writeToCache(withAlpha: false) else { return nil }
                let storyDraft = StoryDraft(filename: url.lastPathComponent,
                                            storyType: .share,
                                            date: Date(),
                                            comment: nil,
                                            desc: String(text.prefix(100)),
                                            url: self.url)
                return storyDraft
            } else  {
                return nil
            }
        } else {
            return nil
        }
    }
}

struct ContentImage: Codable {
    let width: CGFloat
    let height: CGFloat
    let url: String
}

struct ContentBody: Codable {
    let content: String
    let comment: String
    let emoji: EmojiType
}

struct SelectResult: Codable {
    let contactUserList: [UserAvatar]
    var index: Int?
    let percent: Double?
    let emoji: Int?
    struct UserAvatar: Codable {
        let avatar: String
        let userId: UInt64
    }
}

struct CardGetResponse: Codable {
    let card: CardResponse
}
