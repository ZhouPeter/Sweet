//
//  LoginResponse.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum UpdateUserType: UInt, Codable {
    case unknown
    case pushToken
    case avatar
    case nickname
    case gender
    case university
    case college
    case signature
    case enrollment
}

struct LoginResponse: Codable {
    let contactsUpload: Bool
    let register: Bool //isNew
    let token: String
    let user: User
    
    struct User: Codable {
        let userId: UInt64
        let nickname: String
        let avatar: String
        let collegeName: String
        let enrollment: Int
        let gender: Gender
        let phone: String
        let signature: String
        let universityName: String
    }
}
