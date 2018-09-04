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
    var touchPoints: [CGPoint]?
    var comment: String?
    var desc: String?
    var url: String?
    var fromCardId: String?
    let date: Date
    var fileURL: URL {
        var name: String
        if let file = generatedFilename {
            name = file
        } else {
            name = filename
        }
        if storyType.isVideoFile {
            return URL.videoCacheURL(withName: name)
        }
        return URL.photoCacheURL(withName: name)
    }
    var generatedFilename: String?
    var overlayFilename: String?
    var filterFilename: String?
    
    init(filename: String, storyType: StoryType, date: Date) {
        self.filename = filename
        self.storyType = storyType
        self.date = date
    }
    
    init(filename: String, storyType: StoryType, date: Date, comment: String?, desc: String?, url: String?, fromCardId: String) {
        self.init(filename: filename, storyType: storyType, date: date)
        self.comment = comment
        self.desc = desc
        self.url = url
        self.fromCardId = fromCardId
    }
    
    init?(data: StoryDraftData) {
        filename = data.filename
        guard let type = StoryType(rawValue: UInt(data.storyType)) else { return nil }
        storyType = type
        topic = data.topic
        date = data.date
        if !data.touchPoints.isEmpty {
            touchPoints = data.touchPoints.compactMap { CGPoint(rawValue: $0) }
        }
        if let poke = data.pokeCenter {
            pokeCenter = CGPoint(rawValue: poke)
        }
        generatedFilename = data.generatedFilename
        overlayFilename = data.overlayFilename
        filterFilename = data.filterFilename
    }
}
