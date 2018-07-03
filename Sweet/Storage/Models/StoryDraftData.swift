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
    @objc dynamic var contentRect: String?
    @objc dynamic var date = Date()
    
    override static func primaryKey() -> String? {
        return "filename"
    }
    
    class func data(with draft: StoryDraft) -> StoryDraftData {
        let data = StoryDraftData()
        data.filename = draft.filename
        data.storyType = Int(draft.storyType.rawValue)
        data.topic = draft.topic
        data.pokeCenter = draft.pokeCenter?.rawValue
        data.contentRect = draft.contentRect?.rawValue
        data.date = draft.date
        return data
    }
}
