//
//  SubscriptionListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct SubscriptionListResponse: Codable {
    let sections: [SubcriptionSection]
    let users: [Contact]
    let blocks: [Contact]
    let blockSections: [SubcriptionSection]
}

struct SubcriptionSection: Codable {
    let avatar: String
    let info: String
    let name: String
    let sectionId: UInt64
}
