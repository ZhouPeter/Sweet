//
//  AuthPlugin.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya
import SwiftyUserDefaults
class TokenSource {
    var token: String?
    init() {
        token = Defaults[.token]
    }
}

protocol AuthorizedTargetType: TargetType {
    var needsAuth: Bool { get }
}

struct AuthPlugin: PluginType {
    let tokenClosure: () -> String?
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard let token = tokenClosure(), let target = target as? AuthorizedTargetType, target.needsAuth else {
            return request
        }
        var request = request
        request.addValue(token, forHTTPHeaderField: "token")
        return request
    }
}
