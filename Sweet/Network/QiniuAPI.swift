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
        let parameters: [String: Any]
        switch self {
        case let .uploadFile(token, key, fileURL, type):
            parameters = ["token": token, "key": key]
            let data = MultipartFormData(
                                provider: MultipartFormData.FormDataProvider.file(fileURL),
                                name: "file",
                                fileName: fileURL.lastPathComponent,
                                mimeType: type.mimeTypeString())
            return .uploadCompositeMultipart([data], urlParameters: parameters)
        }
    }
    
    var baseURL: URL {
        return URL(string: "https://upload.qiniup.com")!
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
        return [:]
    }
    
}
