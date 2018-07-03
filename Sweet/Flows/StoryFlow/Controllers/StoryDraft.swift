//
//  StoryDraft.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct StoryDraft {
    let filename: String
    let storyType: StoryType
    var topic: String?
    var pokeCenter: CGPoint?
    var contentRect: CGRect?
    let date: Date
    var fileURL: URL {
        if storyType == .image || storyType == .text {
            return URL.photoCacheURL(withName: filename)
        }
        return URL.videoCacheURL(withName: filename)
    }
    
    init(filename: String, storyType: StoryType, date: Date) {
        self.filename = filename
        self.storyType = storyType
        self.date = date
    }
    
    init?(data: StoryDraftData) {
        filename = data.filename
        guard let type = StoryType(rawValue: UInt(data.storyType)) else { return nil }
        storyType = type
        topic = data.topic
        date = data.date
        if let content = data.contentRect {
            contentRect = CGRect(rawValue: content)
        }
        if let poke = data.pokeCenter {
            pokeCenter = CGPoint(rawValue: poke)
        }
    }
}
