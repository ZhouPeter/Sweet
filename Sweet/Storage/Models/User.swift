//
//  User.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class User: Object {
    @objc dynamic var userID: Int64 = 0
    @objc dynamic var avatarURLString: String = ""
    @objc dynamic var nickname: String = ""
    @objc dynamic var phone: String?
    @objc dynamic var university: String?
    @objc dynamic var college: String?
    @objc dynamic var enrollment: Int64 = 0
    @objc dynamic var gender: Int64 = 1
    @objc dynamic var signature: String = ""
    override static func primaryKey() -> String? {
        return "userID"
    }
}
