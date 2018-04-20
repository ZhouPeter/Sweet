//
//  RegisterModel.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum GenderType: UInt {
    case unknown
    case male
    case female
    case other
}
struct RegisterModel {
    
    var universityName: String?
    var collegeName: String?
    var isRegister: String?
    var nickname: String?
    var phone: String?
    var gender: GenderType?
    var smsCode: String?
    var avatar: String?
    var enrollment: Int?
    init() {
        
    }
}
