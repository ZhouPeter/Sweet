//
//  JSONDecoder+Dictionary.swift
//  XPro
//
//  Created by Mario Z. on 2018/3/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension JSONDecoder {
    func decode<T>(_ type: T.Type, from dictionary: [String: Any]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return try decode(type, from: data)
    }
    
    func decode<T>(_ type: T.Type, from array: [[String: Any]]) throws -> T where T: Decodable {
        let data = try JSONSerialization.data(withJSONObject: array, options: [])
        return try decode(type, from: data)
    }
}
