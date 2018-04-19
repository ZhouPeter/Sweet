//
//  String+MD5.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension String {
    var md5: String {
        let length = Int(CC_MD5_DIGEST_LENGTH)
        var digest = [UInt8](repeating: 0, count: length)
        if let data = data(using: String.Encoding.utf8) {
            _ = data.withUnsafeBytes { CC_MD5($0, CC_LONG(data.count), &digest) }
        }
        return (0..<length).reduce("") { $0 + String(format: "%02x", digest[$1]) }
    }
}
