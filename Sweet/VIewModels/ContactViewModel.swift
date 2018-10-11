//
//  ContactViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContactViewModel {
    let avatarURL: URL
    let infoString: String
    let nameString: String
    let userId: UInt64
    let lastTime: Int
    var isHiddenButton: Bool
    var buttonTitle: String?
    var buttonStyle: ContactButtonStyle?
    var callBack: ((String) -> Void)?
    var isHiddeenSelectButton: Bool = true
    init(model: Contact) {
        self.avatarURL = URL(string: model.avatar)!
        self.infoString = model.info
        self.nameString = model.nickname
        self.userId = model.userId
        self.lastTime = model.lastTime
        self.isHiddenButton = true
    }
    
    init(model: Contact, title: String, style: ContactButtonStyle) {
        self.init(model: model)
        self.isHiddenButton = false
        self.buttonTitle = title
        self.buttonStyle = style
    }
}

struct ContactCategoryViewModel {
    let categoryImage: UIImage
    let title: String
}
