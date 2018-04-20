//
//  Response.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct Response<T>: Codable where T: Codable {
    let code: Int
    let data: T
    let msg: String
}
