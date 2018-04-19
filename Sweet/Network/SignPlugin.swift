//
//  SignPlugin.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya

protocol SignedTargetType: TargetType {
    var needsSign: Bool { get }
}

struct SignPlugin: PluginType {
    let signClosure: ([String: Any]) -> String?
    
    func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {
        guard case let .requestParameters(parameters, _) = target.task, let signature = signClosure(parameters) else {
            return request
        }
        var request = request
        request.addValue(signature, forHTTPHeaderField: "sign")
        return request
    }
}
