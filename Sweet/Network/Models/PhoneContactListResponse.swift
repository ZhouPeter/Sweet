//
//  PhoneContactListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
enum PhoneContactStatus: UInt, Codable {
    case notInvited
    case sent
}
enum ResgisterStatus: UInt, Codable {
    case unRegister
    case register
}

struct PhoneContactList: Codable {
    let list: [PhoneContact]
}

struct PhoneContact: Codable {
    let name: String
    let phone: String
    let status: PhoneContactStatus
    let registerStatus: ResgisterStatus
    let avatar: String?
    let info: String?
    let nickname: String?
    let userId: UInt64?
}
