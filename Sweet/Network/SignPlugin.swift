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
        guard let target = target as? SignedTargetType, target.needsSign else {
            return request
        }
        var signature: String?
        if case let .requestParameters(parameters, _) = target.task {
            signature = signClosure(parameters)
        } else if case .requestJSONEncodable = target.task {
            if let data = request.httpBody,
                let json = (try? JSONSerialization.jsonObject(with: data, options: [])) as? [String: Any] {
                signature = signClosure(json)
            }
        }
        guard let sign = signature else { return request }
        var request = request
        request.addValue(sign, forHTTPHeaderField: "sign")
        return request
    }
}
