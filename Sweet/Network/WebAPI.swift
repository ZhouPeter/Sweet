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
    case sendCode(phone: String, type: SendSMSCodeType)
    case logout
    case update(updateParameters: [String: Any])
    case updateRemain
    case phoneChange(phone: String, code: String)
    case uploadContacts(contacts: [[String: Any]])
    case getUserProfile(userId: UInt64)
    case storyList(userId: UInt64)
    case evaluationList(page: Int, userId: UInt64)
    case activityList(page: Int, userId: UInt64, contentId: String?, preferenceId: UInt64?)
    case preferenceList(page: Int, userId: UInt64, contentId: String?, preferenceId: UInt64?)
    case searchUniversity(name: String)
    case searchCollege(collegeName: String, universityName: String)
    case upload(type: UploadType)
    case inviteUrl
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
    case addSectionBlock(sectionId: UInt64)
    case delSectionBlock(sectionId: UInt64)
    case inviteContact(phone: String)
    case searchContact(name: String)
    case allCards(cardId: String?, direction: Direction?)
    case subscriptionCards(cardId: String?, direction: Direction?)
    case evaluateCard(cardId: String, index: Int)
    case choiceCard(cardId: String, index: Int)
    case commentCard(cardId: String, emoji: Int)
    case activityCardLike(cardId: String?, activityId: String, comment: String)
    case storyDetailsUvlist(storyId: UInt64)
    case storyRead(storyId: UInt64, fromCardId: String?)
    case storyTopics
    case searchTopic(topic: String)
    case publishStory(url: String, type: StoryType, topic: String?, pokeCenter: CGPoint?, touchPoints: [CGPoint]?, comment: String?, desc: String?, rawUrl: String?, fromCardId: String?)
    case delStory(storyId: UInt64)
    case socketAddress
    case removeConversation(id: UInt64, isGroup: Bool)
    case getSetting(version: String)
    case shareCard(cardId: String, comment: String, userId: UInt64)
    case shareStory(storyId: UInt64, comment: String, userId: UInt64, fromCardId: String?)
    case likeStory(storyId: UInt64, comment: String, fromCardId: String?)
    case reportStory(storyId: UInt64)
    case sectionStatus(sectionId: UInt64)
    case userStatus(userId: UInt64)
    case cardReport(cardId: String)
    case reviewCard(cardID: String)
    case getCard(cardID: String)
    case getStory(storyID: UInt64)
    case likeEvaluation(evaluationId: UInt64, comment: String)
    case storySortList
    case getVersion
    case reportUser(userID: UInt64)
    case feedback(comment: String, type: Int)
    case cardActionLog(action: String, cardId: String, sectionId: String?, contentId: String?, preferenceId: String?, toUserId: String?, activityId: String?, storyId: String?)
    case recentStoryList(userID: UInt64)
    case updateSetting(autoPlay: Bool, showMsg: Bool)
    case interfaceCallLog(type: Int)
    case quitGroup(groupID: UInt64)
    case joinGroup(cardId: String, contentId: String, groupId: UInt64, comment: String)
    case muteGroup(groupID: UInt64, isMuted: Bool)
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
        case .updateRemain:
            return "/user/update/remain/get"
        case .phoneChange:
            return "/user/phone/change"
        case .uploadContacts:
            return "/user/contacts/upload"
        case .getUserProfile:
            return "/user/profile/get"
        case .storyList:
            return "/user/profile/story/list"
        case .evaluationList:
            return "/user/profile/evaluation/list"
        case .activityList:
            return "/user/profile/activity/list"
        case .preferenceList:
            return "/user/profile/preference/list"
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
        case .addSectionBlock:
            return "/contact/block/section/add"
        case .delSectionBlock:
            return "/contact/block/section/del"
        case .addSectionSubscription:
            return "/contact/subscription/section/add"
        case .delSectionSubscription:
            return "/contact/subscription/section/del"
        case .inviteContact:
            return "/contact/phone/invite"
        case .inviteUrl:
            return "/contact/invite/url"
        case .searchContact:
            return "/contact/search"
        case .storyTopics:
            return "/story/tag/list"
        case .allCards:
            return "/card/all/get"
        case .subscriptionCards:
            return "/card/subscription/get"
        case .evaluateCard:
            return "/card/evaluate"
        case .choiceCard:
            return "/card/choice"
        case .activityCardLike:
            return "/card/activity/like"
        case .storyDetailsUvlist:
            return "/story/details/uvlist"
        case .publishStory:
            return "/story/add"
        case .delStory:
            return "/story/del"
        case .searchTopic:
            return "/story/tag/search"
        case .storyRead:
            return "/story/read"
        case .socketAddress:
            return "/setting/im/routes"
        case .commentCard:
            return "/card/comment"
        case .removeConversation:
            return "/message/del"
        case .getSetting:
            return "/setting/get"
        case .shareCard:
            return "/card/share"
        case .shareStory:
            return "/story/share"
        case .likeStory:
            return "/story/like"
        case .getStory:
            return "/story/get"
        case .reportStory:
            return "/story/report"
        case .sectionStatus:
            return "/contact/section/status"
        case .userStatus:
            return "/contact/user/status"
        case .cardReport:
            return "/card/report"
        case .reviewCard:
            return "/card/review"
        case .getCard:
            return "/card/get"
        case .likeEvaluation:
            return "/user/evaluation/like"
        case .storySortList:
            return "/story/sort/list"
        case .getVersion:
            return "/service/version/get"
        case .reportUser:
            return "/user/report"
        case .feedback:
            return "/user/feedback"
        case .cardActionLog:
            return "/card/action/log"
        case .recentStoryList:
            return "/story/list"
        case .updateSetting:
            return "/user/setting/update"
        case .interfaceCallLog:
            return "/user/externalInterfaceCallLog/record"
        case .quitGroup:
            return "/group/quit"
        case .joinGroup:
            return "/group/join"
        case .muteGroup:
            return "/group/mute"
        }
    }
    
    var task: Task {
        var parameters: [String: Any] = [:]
        switch self {
        case let .verify(phoneNumber, type):
            parameters = ["phone": phoneNumber, "type": "\(type.rawValue)"]
        case let .login(body):
            return .requestJSONEncodable(body)
        case let .sendCode(phone, type):
            parameters = ["phone": phone, "type": type.rawValue]
        case let .update(updateParameters):
            parameters = updateParameters
        case let .phoneChange(phone, code):
            parameters = ["phone": phone, "code": code]
        case let .uploadContacts(contacts):
            parameters = ["contacts": contacts]
        case let .storyList(userId), let .recentStoryList(userId):
            parameters = ["userId": userId]
        case let .evaluationList(page, userId):
            parameters = ["page": page, "userId": userId]
        case let .preferenceList(page, userId, contentId, preferenceId):
            parameters = ["page": page, "userId": userId]
            if let contentId = contentId {
                parameters["contentId"] = contentId
            } else if let preferenceId = preferenceId {
                parameters["preferenceId"] = preferenceId
            }
        case let .activityList(page, userId, contentId, preferenceId):
            parameters = ["page": page, "userId": userId]
            if let contentId = contentId {
                parameters["contentId"] = contentId
            } else if let preferenceId = preferenceId {
                parameters["preferenceId"] = preferenceId
            }
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
             let .delUserSubscription(userId),
             let .userStatus(userId):
            parameters = ["userId": userId]
        case let .addSectionSubscription(sectionId),
             let .delSectionSubscription(sectionId),
             let .sectionStatus(sectionId),
             let .addSectionBlock(sectionId),
             let .delSectionBlock(sectionId):
            parameters = ["sectionId": sectionId]
        case let .inviteContact(phone):
            parameters = ["phone": phone]
        case let .searchContact(name):
            parameters = ["name": name]
        case let .allCards(cardId, direction),
             let .subscriptionCards(cardId, direction):
            if let cardId = cardId, let direction = direction {
                parameters = ["cardId": cardId, "direction": direction.rawValue]
            } else if let cardId = cardId {
                parameters = ["cardId": cardId]
            } else {
                parameters = [:]
            }
        case let .evaluateCard(cardId, index),
             let .choiceCard(cardId, index):
            parameters = ["cardId": cardId, "index": index]
        case let .storyRead(storyId, fromCardId):
            if let fromCardId = fromCardId {
                parameters = ["fromCardId": fromCardId]
            }
            parameters["storyId"] = storyId
        case let .storyDetailsUvlist(storyId),
             let .delStory(storyId),
             let .reportStory(storyId):
            parameters = ["storyId": storyId]
        case let .publishStory(url, type, topic, center, points, comment, desc, rawUrl, fromCardId):
            parameters = ["content": url, "type": type.rawValue]
            if let topic = topic {
                parameters["tag"] = topic
            }
            if let center = center {
                parameters["x"] = center.x
                parameters["y"] = center.y
            }
            if let points = points {
                parameters["touchArea"] = points.map { ["x": $0.x, "y": $0.y] }
            }
            if let comment = comment {
                parameters["comment"] = comment
            }
            if let desc = desc {
                parameters["desc"] = desc
            }
            if let rawUrl = rawUrl {
                parameters["url"] = rawUrl
            }
            if let fromCardId = fromCardId {
                parameters["fromCardId"] = fromCardId
            }
        case let .commentCard(cardId, emoji):
            parameters = ["cardId": cardId, "emoji": emoji]
        case let .removeConversation(id, isGroup):
            if isGroup {
                parameters = ["groupId": id]
            } else {
                parameters = ["userId": id]
            }
        case let .activityCardLike(cardId, activityId, comment):
            parameters = ["activityId": activityId, "comment": comment]
            if let cardId = cardId {
                parameters["cardId"] = cardId
            }
        case let .getSetting(version):
            parameters = ["version": version]
        case let .shareCard(cardId, comment, userId):
            parameters = ["cardId": cardId, "comment": comment, "userId": userId]
        case let .shareStory(storyId, comment, userId, fromCardId):
            parameters = ["storyId": storyId, "comment": comment, "userId": userId]
            if let fromCardId = fromCardId {
                parameters = ["fromCardId": fromCardId]
            }
        case let .likeStory(storyId, comment, fromCardId):
            parameters = ["storyId": storyId, "comment": comment]
            if let fromCardId = fromCardId {
                parameters["fromCardId"] = fromCardId
            }
        case .cardReport(let cardID), .reviewCard(let cardID), .getCard(let cardID):
            parameters = ["cardId": cardID]
        case .getStory(let storyID):
            parameters = ["storyId": storyID]
        case let .likeEvaluation(cardId, comment):
            parameters = ["cardId": cardId, "comment": comment]
        case .searchTopic(let topic):
            parameters = ["tag": topic]
        case .getVersion:
            parameters = ["type": 1]
        case .reportUser(let userID):
            parameters = ["userId": userID]
        case .feedback(let comment, let type):
            parameters = ["comment": comment, "type": type]
        case let .cardActionLog(action, cardId, sectionId, contentId, preferenceId, toUserId, activityId, storyId):
            parameters = ["action" : action, "cardId": cardId]
            parameters["sectionId"] = sectionId
            parameters["contentId"] = contentId
            parameters["preferenceId"] = preferenceId
            parameters["toUserId"] = toUserId
            parameters["activityId"] = activityId
            parameters["storyId"] = storyId
        case let .updateSetting(autoPlay, showMsg):
            parameters = ["autoPlay": autoPlay, "showMsg": showMsg]
        case let .interfaceCallLog(`type`):
            parameters = ["type": type]
        case .quitGroup(let groupID):
            parameters = ["groupId": groupID]
        case let .joinGroup(cardId, contentId, groupId, comment):
            parameters = ["cardId": cardId, "contentId": contentId, "groupId": groupId, "comment": comment]
        case .muteGroup(let groupID, let isMuted):
            parameters = ["groupId": groupID, "mute": isMuted]
        default:
            break
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

enum SendSMSCodeType: Int {
    case unknown
    case login
    case register
    case changeNumber
}
