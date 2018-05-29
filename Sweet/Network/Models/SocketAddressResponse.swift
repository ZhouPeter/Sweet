//
//  SocketAddressResponse.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct SocketAddressResponse: Codable {
    let routes: [SocketAddress]
}

struct SocketAddress: Codable {
    let host: String
    let port: Int
}
