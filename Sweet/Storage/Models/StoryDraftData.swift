//
//  StoryDraftData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class StoryDraftData: Object {
    @objc dynamic var filename = ""
    @objc dynamic var storyType = 0
    @objc dynamic var topic: String?
    @objc dynamic var pokeCenter: String?
    @objc dynamic var touchPoints: [String]?
    @objc dynamic var date = Date()
    @objc dynamic var generatedFilename: String?
    @objc dynamic var overlayFilename: String?
    @objc dynamic var filterFilename: String?
    
    override static func primaryKey() -> String? {
        return "filename"
    }
    
    class func data(with draft: StoryDraft) -> StoryDraftData {
        let data = StoryDraftData()
        data.filename = draft.filename
        data.storyType = Int(draft.storyType.rawValue)
        data.topic = draft.topic
        data.pokeCenter = draft.pokeCenter?.rawValue
        data.touchPoints = draft.touchPoints?.flatMap { $0.rawValue }
        data.date = draft.date
        data.filterFilename = draft.filterFilename
        data.generatedFilename = draft.generatedFilename
        data.overlayFilename = draft.overlayFilename
        return data
    }
}
