//
//  SearchUniversityResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct SearchUniversityResponse: Codable {
    let universityInfos: [University]
   
}

struct University: Codable {
    let universityName: String
    let city: String
}
