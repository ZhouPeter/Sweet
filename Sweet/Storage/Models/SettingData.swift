//
//  SettingData.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import RealmSwift

class SettingData: Object {
    @objc dynamic var userID: Int64 = 0
    @objc dynamic var autoPlay: Bool = true
    @objc dynamic var showMsg: Bool = true
    
    override static func primaryKey() -> String? {
        return "userID"
    }
    
    class func data(with setting: UserSetting) -> SettingData {
        let data = SettingData()
        data.userID = Int64(setting.userId)
        data.autoPlay = setting.autoPlay
        data.showMsg = setting.showMsg
        return data
    }
}

extension UserSetting {
    init(data: SettingData) {
        self.userId = UInt64(data.userID)
        self.autoPlay = data.autoPlay
        self.showMsg = data.showMsg
    }
}
