//
//  EvaluationListResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct EvaluationListResponse: Codable {
    let list: [EvaluationResponse]
}

struct EvaluationResponse: Codable {
    let evaluationId: UInt64
    let fromCardId: String
    let image: String
    var like: Bool
    let text: String
    let num: Int
}
