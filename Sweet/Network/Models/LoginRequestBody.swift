//
//  LoginRequestBody.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct LoginRequestBody: Codable {
    var avatar: String?
    var collegeName: String?
    var enrollment: Int?
    var gender: Gender?
    var nickname: String?
    var phone: String?
    var smsCode: String?
    var universityName: String?
    var register: Bool = false
    
    init(phone: String? = nil, smsCode: String? = nil) {
        self.phone = phone
        self.smsCode = smsCode
    }
    
    init() {
        
    }
}
