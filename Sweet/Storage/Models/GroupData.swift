//
//  GroupData.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/20.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation
import RealmSwift

class GroupData: Object {
    @objc dynamic var id: Int64 = 0
    @objc dynamic var name = ""
    @objc dynamic var memberCount: Int = 0
    @objc dynamic var avatarURL = ""
    
    override static func primaryKey() -> String? {
        return "id"
    }
    
    class func data(with group: Group) -> GroupData {
        let data = GroupData()
        data.id = Int64(group.id)
        data.name = group.name
        data.memberCount = group.memberCount
        data.avatarURL = group.avatarURL?.absoluteString ?? ""
        return data
    }
    
    func makeGroup() -> Group {
        return Group(id: UInt64(id),
                     name: name,
                     memberCount: memberCount,
                     avatarURL: URL(string: avatarURL))
    }
}
