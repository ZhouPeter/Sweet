//
//  PhoneContactViewModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct PhoneContactViewModel {
    var firstNameString: String?
    let nameString: String
    var infoString: String?
    var avatarURL: URL?
    let isHiddenButton: Bool
    var buttonTitle: String = "邀请"
    var buttonStyle: ContactButtonStyle = .borderBlue
    let nameCenterYOffsetAvatar: CGFloat
    init(model: PhoneContact) {
        if model.registerStatus == .unRegister {
            self.isHiddenButton = false
            self.nameString = model.name
            if model.status == .notInvited {
                self.buttonTitle = "邀请"
                self.buttonStyle = .borderBlue
            } else {
                self.buttonTitle = "已发送"
                self.buttonStyle = .noBorderGray
            }
            self.firstNameString = String(model.name.first ?? Character(""))
            self.nameCenterYOffsetAvatar = 0
        } else {
            self.isHiddenButton = true
            self.nameString = "\(model.nickname!)（通讯录名称：\(model.name)）"
            self.avatarURL = URL(string: model.avatar!)
            self.infoString = model.info
            self.nameCenterYOffsetAvatar = -10
        }
    }
}
