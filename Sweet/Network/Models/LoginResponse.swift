//
//  LoginResponse.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct LoginResponse: Codable {
    let contactsUpload: Bool
    let register: Bool //isNew
    let token: String
    let user: User
    
    struct User: Codable {
        let userId: UInt64
        var nickname: String?
        let avatar: String
        var collegeName: String?
        var enrollment: Int?
        var gender: Gender?
        var phone: String?
        var signature: String?
        var universityName: String?
    }
}
