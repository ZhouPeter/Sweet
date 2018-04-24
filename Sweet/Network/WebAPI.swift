//
//  WebAPI.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Moya

enum WebAPI {
    case verify(phoneNumber: String, type: VerificationType)
    case login(body: LoginRequestBody)
    case logout
    case searchUniversity(name: String)
    case searchCollege(collegeName: String, universityName: String)
    case upload(type: UploadType)
}

extension WebAPI: TargetType, AuthorizedTargetType, SignedTargetType {
    var path: String {
        switch self {
        case .verify:
            return "/v2/user/send/verification"
        case .login:
            return "/v2/user/login"
        case .logout:
            return "/v2/user/logout"
        case .searchUniversity:
            return "/v2/network/university/search"
        case .searchCollege:
            return "/v2/network/college/search"
        case .upload:
            return "/v2/service/upload/get"
        }
    }
    
    var task: Task {
        let parameters: [String: Any]
        switch self {
        case let .verify(phoneNumber, type):
            parameters = ["phone": phoneNumber, "type": "\(type.rawValue)"]
        case let .login(body):
            return .requestJSONEncodable(body)
        case let .searchUniversity(name):
            parameters = ["universityName": name]
        case let .searchCollege(collegeName, universityName):
            parameters = ["collegeName": collegeName, "universityName": universityName]
        case let .upload(type):
            parameters = ["type": type.rawValue]
        default:
            parameters = [:]
        }
        return .requestParameters(parameters: parameters, encoding: JSONEncoding.default)
    }
    
    var needsSign: Bool {
        return true
    }
    
    var needsAuth: Bool {
        switch self {
        case .verify, .login:
            return false
        default:
            return true
        }
    }
    
    var method: Moya.Method {
        return .post
    }
    
    var baseURL: URL {
        #if DEV
        return URL(string: "https://sweet-api-t.miaobo.me")!
        #else
        return URL(string: "https://sweet-api.miaobo.me")!
        #endif
    }
    
    var sampleData: Data {
        return Data()
    }
    
    var headers: [String: String]? {
        return ["appversion": appVersion]
    }
}

private let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.0"

enum VerificationType: Int {
    case login = 2
    case register = 3
}

