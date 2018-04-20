//
//  Signer.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct Signer {
    static func sign(_ parameters: [String: Any]) -> String {
        var queryString = query(parameters)
        #if DEV
        queryString += "&secret=ktjfbkwxhmkk6z3"
        #else
        queryString += "&secret=iulyn5yxzagkwo5"
        #endif
        return queryString.md5
    }
    
    private static func query(_ parameters: [String: Any]) -> String {
        var components: [(String, String)] = []
        for key in parameters.keys.sorted(by: <) {
            let value = parameters[key]!
            components += queryComponents(fromKey: key, value: value)
        }
        return components.map { "\($0)=\($1)" }.joined(separator: "&")
    }
    
    private static func queryComponents(fromKey key: String, value: Any) -> [(String, String)] {
        var components: [(String, String)] = []
        
        if let dictionary = value as? [String: Any] {
            for (nestedKey, value) in dictionary {
                components += queryComponents(fromKey: "\(key)[\(nestedKey)]", value: value)
            }
        } else if let array = value as? [Any] {
            for value in array {
                components += queryComponents(fromKey: key, value: value)
            }
        } else if let value = value as? NSNumber {
            if value.isBool {
                components.append((key, value: value.boolValue.string))
            } else {
                components.append((key, "\(value)"))
            }
        } else if let bool = value as? Bool {
            components.append((key, value: bool.string))
        } else {
            components.append((key, "\(value)"))
        }
        return components
    }
}

extension Bool {
    var string: String {
        return self ? "true" : "false"
    }
}

extension NSNumber {
    fileprivate var isBool: Bool { return CFBooleanGetTypeID() == CFGetTypeID(self) }
}
