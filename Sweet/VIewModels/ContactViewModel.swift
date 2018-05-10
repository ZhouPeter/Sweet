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
    var callBack: ((UInt64) -> Void)?
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

struct ContactSubcriptionSectionViewModel {
    let avatarURL: URL
    let infoString: String
    let nameString: String
    let sectionId: UInt64
    let isHiddenButton: Bool
    var buttonTitle: String
    var buttonStyle: ContactButtonStyle
    var callBack: ((UInt64) -> Void)?
    init(model: SubcriptionSection) {
        self.isHiddenButton = false
        self.avatarURL = URL(string: model.avatar)!
        self.infoString = model.info
        self.nameString = model.name
        self.sectionId = model.sectionId
        self.buttonTitle = "已订阅"
        self.buttonStyle = .borderBlue
    }
}