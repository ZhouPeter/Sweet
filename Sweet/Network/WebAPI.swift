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
    case sendCode(phone: String, type: Int)
    case logout
    case update(updateParameters: [String: Any])
    case phoneChange(phone: String, code: String)
    case uploadContacts(contacts: [[String: Any]])
    case getUserProfile(userId: UInt64)
    case storyList(page: Int, userId: UInt64)
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
        case .sendCode:
            return "/v2/user/send/verification"
        case .logout:
            return "/v2/user/logout"
        case .update:
            return "/v2/user/update"
        case .phoneChange:
            return "/v2/user/phone/change"
        case .uploadContacts:
            return "/v2/user/contacts/upload"
        case .getUserProfile:
            return "/v2/user/profile/get"
        case .storyList:
            return "/v2/user/profile/story/list"
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
        case let .sendCode(phone, type):
            parameters = ["phone": phone, "type": type]
        case let .update(updateParameters):
            parameters = updateParameters
        case let .phoneChange(phone, code):
            parameters = ["phone": phone, "code": code]
        case let .uploadContacts(contacts):
            parameters = ["contacts": contacts]
        case let .getUserProfile(userId):
            parameters = ["userId": userId]
        case let .storyList(page, userId):
            parameters = ["page": page, "userId": userId]
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
        return web.tokenSource.token != nil
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
