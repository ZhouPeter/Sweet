//
//  Group.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/20.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation

struct Group {
    let id: UInt64
    var name: String
    var memberCount: Int
    var avatarURL: URL?
    var isMuted: Bool
    
    init(proto: GroupInfo) {
        id = proto.groupID
        name = proto.name
        memberCount = Int(proto.memberNum)
        avatarURL = URL(string: proto.icon)
        isMuted = proto.mute
    }
    
    init(id: UInt64, name: String, memberCount: Int, avatarURL: URL?, isMuted: Bool) {
        self.id = id
        self.name = name
        self.memberCount = memberCount
        self.avatarURL = avatarURL
        self.isMuted = isMuted
    }
}
