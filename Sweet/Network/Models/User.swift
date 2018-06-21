//
//  User.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable redundant_optional_initialization

import Foundation

struct User: Codable {
    let userId: UInt64
    let nickname: String
    let avatar: String
    let enrollment: Int
    let gender: Gender
    var phone: String? = nil
    let signature: String
    var collegeName: String? = nil
    var universityName: String? = nil
    var city: String? = nil
    var userType: Int32? = nil
    var isBlacklisted: Bool?
}

enum Gender: Int, Codable {
    case unknown
    case male
    case female
    case other
}
