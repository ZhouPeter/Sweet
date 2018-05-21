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
    case getStoryTopics
    case allCards
    case subscriptionCards
    case storyDetailsUvlist(storyId: UInt64)
}

extension WebAPI: TargetType, AuthorizedTargetType, SignedTargetType {
    var path: String {
        switch self {
        case .verify:
            return "/user/send/verification"
        case .login:
            return "/user/login"
        case .sendCode:
            return "/user/send/verification"
        case .logout:
            return "/user/logout"
        case .update:
            return "/user/update"
        case .phoneChange:
            return "/user/phone/change"
        case .uploadContacts:
            return "/user/contacts/upload"
        case .getUserProfile:
            return "/user/profile/get"
        case .storyList:
            return "/user/profile/story/list"
        case .searchUniversity:
            return "/network/university/search"
        case .searchCollege:
            return "/network/college/search"
        case .upload:
            return "/service/upload/get"
        case .contactAllList:
            return "/contact/all/list"
        case .phoneContactList:
            return "/contact/phone/list"
        case .blackContactList:
            return "/contact/blacklist/list"
        case .addBlacklist:
            return "/contact/blacklist/add"
        case .delBlacklist:
            return "/contact/blacklist/del"
        case .blockContactList:
            return "/contact/block/list"
        case .addBlock:
            return "/contact/block/add"
        case .delBlock:
            return "/contact/block/del"
        case .subscriptionList:
            return "/contact/subscription/list"
        case .addUserSubscription:
            return "/contact/subscription/user/add"
        case .delUserSubscription:
            return "/contact/subscription/user/del"
        case .addSectionSubscription:
            return "/contact/subscription/section/add"
        case .delSectionSubscription:
            return "/contact/subscription/section/del"
        case .inviteContact:
            return "/contact/phone/invite"
        case .searchContact:
            return "/contact/search"
        case .getStoryTopics:
            return "/story/tag/list"
        case .allCards:
            return "/card/all/get"
        case .subscriptionCards:
            return "/card/subscription/get"
        case .storyDetailsUvlist:
            return "/story/details/uvlist"
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
        case let .storyDetailsUvlist(storyId):
            parameters = ["storyId": storyId]
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
        return URL(string: "https://sweet-api-t.miaobo.me/v2")!
        #else
        return URL(string: "https://sweet-api.miaobo.me/v2")!
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
