//
//  QiniuAPI.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya

enum QiniuAPI {
    case uploadFile(token: String, key: String, fileURL: URL, type: UploadType)
}

extension QiniuAPI: TargetType {
    var task: Task {
        switch self {
        case let .uploadFile(token, key, fileURL, type):
            let data = MultipartFormData(
                                provider: MultipartFormData.FormDataProvider.file(fileURL),
                                name: "file",
                                fileName: fileURL.lastPathComponent,
                                mimeType: type.mimeTypeString())
            let tokenValue = token.data(using: .utf8)
            let tokenData = MultipartFormData(provider: .data(tokenValue!), name: "token")
            let keyValue = key.data(using: .utf8)
            let keyData = MultipartFormData(provider: .data(keyValue!), name: "key")
            return .uploadMultipart([data, tokenData, keyData])
        }
    }
    
    var baseURL: URL {
        return URL(string: "http://upload.qiniu.com")!
    }
    
    var path: String {
        switch self {
        case .uploadFile:
            return ""
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return nil
    }
    
}
