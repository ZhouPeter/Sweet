//
//  UploadTokenResponse.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

enum UploadType: UInt, Codable {
    case userAvatar = 1
    case storyImage
    
    func mimeTypeString() -> String {
        switch self {
        case .userAvatar, .storyImage:
            return "image/jpeg"
        }
    }
}

struct UploadTokenResponse: Codable {
    let host: String
    let key: String
    let token: String
}
