//
//  MessageContent.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol MessageContent: Codable {
    func encoded() -> String
}

extension MessageContent {
    func encoded() -> String {
        var string: String?
        do {
            let data = try JSONEncoder().encode(self)
            string = String(data: data, encoding: .utf8)
        } catch {
            logger.error(error)
        }
        return string ?? ""
    }
}
