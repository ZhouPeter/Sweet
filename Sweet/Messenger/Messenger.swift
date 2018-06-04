//
//  Messenger.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable weak_delegate

import Foundation
import libimcloud
import Alamofire
import SwiftProtobuf

enum MessengerState {
    case offline
    case connecting
    case logining
    case online
}

#if DEV
private let secret = "ktjfbkwxhmkk6z3"
#else
private let secret = "iulyn5yxzagkwo5"
#endif

final class Messenger {
    static let shared = Messenger()
    private(set) var state = MessengerState.offline {
        didSet {
            multicastDelegate.invoke({ $0.messengerDidUpdateState(state) })
        }
    }
    private(set) var isNetworkReachable = false {
        didSet {
            if isNetworkReachable && user != nil && token != nil {
                connect()
            }
        }
    }
    private var multicastDelegate = MulticastDelegate<MessengerDelegate>()
    private var user: User?
    private var token: String?
    private var serverDate: Date? {
        didSet {
            multicastDelegate.invoke({ $0.messengerDidUpdateServerDate(serverDate) })
        }
    }
    private var service: ImCloudService {
        guard let service = ImCloudService.sharedInstance() else { fatalError() }
        return service
    }
    private let reachabilityManager = NetworkReachabilityManager(host: WebAPI.socketAddress.baseURL.absoluteString)
    private var storage: Storage?
    
    private init() {
        startNetworkReachabilityObserver()
    }
    
    // MARK: - Public
    
    func addDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }
    
    func removeDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }
    
    func login(with user: User, token: String) {
        self.user = user
        storage = Storage(userID: user.userId)
        self.token = token
        guard isNetworkReachable else {
            logger.debug("Waiting network")
            return
        }
        guard state == .offline else {
            logger.debug("state is \(state)")
            return
        }
        connect()
    }
    
    func logout() {
        guard let user = self.user else { return }
        self.user = nil
        storage = nil
        token = nil
        state = .offline
        service.stop {
            logger.debug("Service stopped")
            self.multicastDelegate.invoke({ $0.messengerDidLogout(user: user) })
        }
    }
    
    func getUserInfo(with userID: UInt64) {
        getUserInfoList(with: [userID]) { (userList) in
            logger.debug(userList)
        }
    }
    
    func getUserInfoList(with userIDs: [UInt64], callback: @escaping ([User]) -> Void) {
        var request = UserInfoGetReq()
        request.userIDList = userIDs
        send(request, responseType: UserInfoGetResp.self, callback: { response in
            var userList = [User]()
            guard let response = response else {
                callback(userList)
                return
            }
            self.storage?.write({ (realm) in
                let users = response.userInfoList.map(UserData.data(with:))
                userList = users.map(User.init)
                realm.add(users, update: true)
            }, callback: { (_) in
                callback(userList)
            })
        })
    }
    
    // MARK: - Messages
    
    @discardableResult func sendText(_ text: String, from: UInt64, to: UInt64) -> InstantMessage {
        var message = InstantMessage()
        message.content = text
        message.type = .text
        message.to = to
        message.from = from
        send(message)
        return message
    }
    
    func send(_ message: InstantMessage) {
        guard state == .online else {
            multicastDelegate.invoke({ $0.messengerDidSendMessage(message, success: false) })
            return
        }
        let request = message.makeSendRequest()
        saveMessages([message])
        send(request, responseType: SendResp.self) { (response) in
            guard let response = response, response.resultCode == 0 else {
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(message, success: false) })
                return
            }
            var messageSent = message
            messageSent.remoteID = response.msgID
            messageSent.sentDate = Date()
            messageSent.isSent = true
            self.serverDate = Date(timeIntervalSince1970: Double(response.timestamp) / 1000)
            self.saveMessages([message], callback: {
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(messageSent, success: true) })
            })
        }
    }
    
    // MARK: - Conversations
    
    func loadConversations() {
        logger.debug()
        guard let userID = user?.userId, state == .online else { return }
        var request = RecentGetReq()
        request.from = userID
        send(request, responseType: RecentGetResp.self) { (response) in
            guard let response = response else { return }
            self.saveMessages(response.msgList.map(InstantMessage.init), callback: {
                var conversations = [Conversation]()
                self.storage?.read({ (realm) in
                    conversations = realm.objects(ConversationData.self).compactMap(Conversation.init)
                }, callback: {
                    self.multicastDelegate.invoke({ $0.messengerDidUpdateConversations(conversations) })
                })
            })
        }
    }
    
    func removeConversation(userID: UInt64) {
//        guard let index = conversations.index(where: { $0.user.userId == userID }) else { return }
//        conversations.remove(at: index)
    }
    
    // MARK: - Private
    
    private func getMessages(with IDs: [UInt64], callback: @escaping ([InstantMessage]) -> Void) {
        var request = GetReq()
        request.msgIDList = IDs
        send(request, responseType: GetResp.self) { (response) in
            guard let response = response else { return }
            let messages = response.msgList.map(InstantMessage.init)
            self.storage?.write({ (realm) in
                realm.add(messages.map(InstantMessageData.data(with:)), update: true)
            }, callback: { (_) in
                callback(messages)
            })
        }
    }
    
    private func listenMessageNotify() {
        let handler = MessageHandler<Notify> { (note) in
            let package = ImPackageRawdata()
            package.body = try? NotifyAck().serializedData()
            self.service.send(
                package,
                moduleId: ModuleID.message.rawValue,
                commandId: MsgCmdID.notifyAck.rawValue,
                onMessageSend: nil
            )
            logger.debug(note ?? "")
            guard let notify = note else { return }
            self.getMessages(with: [notify.msgID], callback: { (messages) in
                guard let message = messages.first else { return }
                self.updateUserConversations(with: [message.from])
                self.multicastDelegate.invoke({ $0.messengerDidReceiveMessage(message) })
            })
        }
        HandlerManager.sharedInstance()
            .addHandler(ModuleID.message.rawValue, commandId: MsgCmdID.notify.rawValue, handler: handler)
    }
    
    private func saveMessages(_ messages: [InstantMessage], callback: (() -> Void)? = nil) {
        guard let userID = user?.userId else {
            logger.warning("User is nil")
            return
        }
        var userIDs = Set<UInt64>()
        storage?.write({ (realm) in
            var dataArray = [InstantMessageData]()
            messages.forEach({ (message) in
                logger.debug(message)
                dataArray.append(InstantMessageData.data(with: message))
                userIDs.insert(message.from == userID ? message.to : message.from)
            })
            realm.add(dataArray, update: true)
        }, callback: { (_) in
            self.updateUserConversations(with: Array(userIDs))
            callback?()
        })
    }
    
    private func updateUserConversations(with userIDs: [UInt64]) {
        guard userIDs.isNotEmpty else { return }
        var conversations = [Conversation]()
        var userIDsNotSaved = [UInt64]()
        storage?.write({ (realm) in
            userIDs.forEach({ (userID) in
                if let userData = realm.object(ofType: UserData.self, forPrimaryKey: Int64(userID)) {
                    let results = realm.objects(InstantMessageData.self).filter("from = \(userID) || to = \(userID)")
                        .sorted(byKeyPath: "sentDate")
                    if let conversationData = realm
                        .object(ofType: ConversationData.self, forPrimaryKey: Int64(userID)) {
                        if let messageData = results.last {
                            conversationData.lastMessage = messageData
                            conversationData.date = messageData.sentDate
                            if messageData.isRead == false {
                                conversationData.unreadCount += 1
                            }
                            conversations.append(Conversation(data: conversationData)!)
                        } else {
                            logger.error("Message not written for user \(userID)")
                        }
                    } else {
                        let conversationData = ConversationData()
                        conversationData.userID = userData.userID
                        conversationData.user = userData
                        if let last = results.last {
                            results.forEach({ (data) in
                                if data.isRead == false {
                                    conversationData.unreadCount += 1
                                }
                            })
                            conversationData.lastMessage = last
                            conversationData.date = last.sentDate
                            conversations.append(Conversation(data: conversationData)!)
                        } else {
                            logger.error("Message not written for user \(userID)")
                        }
                    }
                } else {
                    userIDsNotSaved.append(userID)
                }
            })
        }, callback: { _ in
            logger.debug("conversations: \(conversations)", "userIdsNotSaved \(userIDsNotSaved)")
            if userIDsNotSaved.isNotEmpty {
                self.getUserInfoList(with: userIDsNotSaved, callback: { (users) in
                    self.updateUserConversations(with: users.map({ $0.userId }))
                })
            }
            self.multicastDelegate.invoke({ $0.messengerDidUpdateConversations(conversations) })
        })
    }
    
    private func startNetworkReachabilityObserver() {
        reachabilityManager?.listener = { status in
            switch status {
            case .notReachable, .unknown:
                logger.error(status)
                self.isNetworkReachable = false
            default:
                logger.debug("Network is OK")
                self.isNetworkReachable = true
            }
        }
        reachabilityManager?.startListening()
    }
    
    private func connect() {
        guard let user = self.user else {
            logger.debug("user is nil")
            return
        }
        state = .connecting
        web.request(.socketAddress, responseType: Response<SocketAddressResponse>.self) { (result) in
            if case let .failure(error) = result {
                logger.error(error)
                self.state = .offline
                return
            }
            guard case let .success(response) = result, let address = response.routes.first else {
                self.state = .offline
                return
            }
            self.connect(with: address, completion: {
                self.login({ (date) in
                    if let date = date {
                        self.serverDate = date
                        self.state = .online
                    } else {
                        self.state = .offline
                    }
                    self.listenMessageNotify()
                    self.multicastDelegate.invoke({ $0.messengerDidLogin(user: user, success: date != nil) })
                })
            })
        }
    }
    
    private func login(_ callback: @escaping (Date?) -> Void) {
        guard let user = self.user, let token = self.token else {
            logger.debug("User is nil")
            callback(nil)
            return
        }
        var message = LoginReq()
        message.userID = user.userId
        let timestamp = Date().timestamp()
        message.timestamp = timestamp
        message.signature = "timestamp=\(timestamp)&token=\(token)&user_id=\(user.userId)&secret=\(secret)".md5
        message.token = token
        message.type = .ios
        message.state = .online
        send(message, responseType: LoginResp.self) { (response) in
            if let response = response {
                callback(Date(timeIntervalSince1970: Double(response.serverTime) / 1000))
            } else {
                callback(nil)
            }
        }
    }
    
    private func connect(with address: SocketAddress, completion: @escaping () -> Void) {
        service.start(address.host, port: address.port, onConnected: {
            logger.debug("Service connected")
            completion()
        }, onClosed: {
            logger.debug("Service closed")
            self.state = .offline
        })
    }
    
    private func send<T, R> (
        _ message: T,
        responseType: R.Type,
        callback: @escaping (R?) -> Void) where T: Message & MessageTicket, R: Message {
        let module = message.module.rawValue
        let command = message.command
        HandlerManager.sharedInstance()
            .addHandler(module, commandId: command + 1, handler: MessageHandler<R>(callback: callback))
        let package = ImPackageRawdata()
        package.body = try? message.serializedData()
        if package.body == nil { logger.error("package body is nil") }
        service.send(package, moduleId: module, commandId: command) { (code) in
            if code.rawValue != 0 {
                logger.error("message send failed", message)
                callback(nil)
            }
        }
    }
}
