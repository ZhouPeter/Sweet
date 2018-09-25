//
//  SearchContactResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/10.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct SearchContactResponse: Codable {
    let blacklists: [Contact]
    let blocks: [Contact]
    let contacts: [Contact]
    let phoneContacts: [PhoneContact]
    let subscriptions: [Contact]
    let users: [Contact]
    
}
