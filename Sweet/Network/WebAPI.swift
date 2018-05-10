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
    case contactAllList
    case phoneContactList
    case blackContactList
    case addBlacklist(userId: UInt64)
    case delBlacklist(userId: UInt64)
    case blockContactList
    case addBlock(userId: UInt64)
    case delBlock(userId: UInt64)
    case subscriptionList
    case addUserSubscription(userId: UInt64)
    case delUserSubscription(userId: UInt64)
    case addSectionSubscription(sectionId: UInt64)
    case delSectionSubscription(sectionId: UInt64)
    case inviteContact(phone: String)
    case searchContact(name: String)
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
        case .contactAllList:
            return "/v2/contact/all/list"
        case .phoneContactList:
            return "/v2/contact/phone/list"
        case .blackContactList:
            return "/v2/contact/blacklist/list"
        case .addBlacklist:
            return "/v2/contact/blacklist/add"
        case .delBlacklist:
            return "/v2/contact/blacklist/del"
        case .blockContactList:
            return "/v2/contact/block/list"
        case .addBlock:
            return "/v2/contact/block/add"
        case .delBlock:
            return "/v2/contact/block/del"
        case .subscriptionList:
            return "/v2/contact/subscription/list"
        case .addUserSubscription:
            return "/v2/contact/subscription/user/add"
        case .delUserSubscription:
            return "/v2/contact/subscription/user/del"
        case .addSectionSubscription:
            return "/v2/contact/subscription/section/add"
        case .delSectionSubscription:
            return "/v2/contact/subscription/section/del"
        case .inviteContact:
            return "/v2/contact/phone/invite"
        case .searchContact:
            return "/v2/contact/search"
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
        case let .storyList(page, userId):
            parameters = ["page": page, "userId": userId]
        case let .searchUniversity(name):
            parameters = ["universityName": name]
        case let .searchCollege(collegeName, universityName):
            parameters = ["collegeName": collegeName, "universityName": universityName]
        case let .upload(type):
            parameters = ["type": type.rawValue]
        case let .getUserProfile(userId),
             let .addBlacklist(userId),
             let .delBlacklist(userId),
             let .addBlock(userId),
             let .delBlock(userId),
             let .addUserSubscription(userId),
             let .delUserSubscription(userId):
            parameters = ["userId": userId]
        case let .addSectionSubscription(sectionId),
             let .delSectionSubscription(sectionId):
            parameters = ["sectionId": sectionId]
        case let .inviteContact(phone):
            parameters = ["phone": phone]
        case let .searchContact(name):
            parameters = ["name": name]
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
