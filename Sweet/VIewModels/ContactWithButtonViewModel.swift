//
//  BlackContactViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct ContactWithButtonViewModel {
    let avatarURL: URL
    let infoString: String
    let nameString: String
    let userId: UInt64
    var buttonTitle: String
    var buttonStyle: ContactButtonStyle
    let isHiddenButton: Bool
    var callBack: ((UInt64) -> Void)?
    init(model: Contact) {
        self.isHiddenButton = false
        self.avatarURL = URL(string: model.avatar)!
        self.infoString = model.info
        self.nameString = model.nickname
        self.userId = model.userId
        self.buttonTitle = "恢复"
        self.buttonStyle = .borderGray
    }
    init(model: Contact, buttonTitle: String) {
        self.init(model: model)
        self.buttonTitle = buttonTitle
        self.buttonStyle = .borderBlue
    }
}

struct ContactSubcriptionSectionViewModel {
    let avatarURL: URL
    let infoString: String
    let nameString: String
    let sectionId: UInt64
    let isHiddenButton: Bool
    let buttonTitle: String
    let buttonStyle: ContactButtonStyle
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
