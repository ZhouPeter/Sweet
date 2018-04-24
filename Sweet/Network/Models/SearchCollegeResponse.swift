//
//  SearchCollegeResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct SearchCollegeResponse: Codable {
    let collegeInfos: [College]
}

struct College: Codable {
    let universityName: String
    let collegeName: String
}
