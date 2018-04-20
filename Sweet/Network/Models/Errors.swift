//
//  Errors.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

let webErrorDomain = "WebErrorDomain"

enum WebErrorCode: Int, Codable {
    case parse = -2
    case http = -1
    case none = 0
    case service = 500
    case parameter = 100001
    case signature = 100002
    case authorization = 100100
    case userIsNil = 100101
    case verification = 100102
    case verificationSend = 100103
    case updateLimit = 100104
}

extension NSError {
    convenience init(code: WebErrorCode, description: String? = nil) {
        self.init(code: code.rawValue, description: description)
    }
    
    convenience init(code: Int, description: String? = nil) {
        var userInfo = [String: Any]()
        if  let description = description {
            userInfo[NSLocalizedDescriptionKey] = description
        }
        self.init(domain: webErrorDomain, code: code, userInfo: userInfo)
    }
}
