//
//  Messenger.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable weak_delegate
// swiftlint:disable file_length
// swiftlint:disable type_body_length

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
    private var conversationUserID: UInt64?
    private var messagesUnreadCount: Int? {
        didSet {
            if let count = messagesUnreadCount {
                DispatchQueue.main.async {
                    UIApplication.shared.applicationIconBadgeNumber = count
                }
            }
        }
    }
    
    private init() {
        startNetworkReachabilityObserver()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateActiveStatus),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateActiveStatus),
            name: .UIApplicationWillEnterForeground,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(syncBadgeNumber),
            name: .UIApplicationDidEnterBackground,
            object: nil
        )
        
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
    
    @objc func updateActiveStatus() {
        var request = ActiveSyncReq()
        request.status = UIApplication.shared.applicationState == .background ? .background : .foreground
        send(request, responseType: ActiveSyncResp.self, callback: nil)
    }
    
    // MARK: - Messages
    
    func send(_ message: InstantMessage) {
        guard state == .online else {
            multicastDelegate.invoke({ $0.messengerDidSendMessage(message, success: false) })
            return
        }
        let request = message.makeSendRequest()
        saveMessages([message], update: true)
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
            self.saveMessages([messageSent], update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(messageSent, success: true) })
            })
        }
    }
    
    func loadMessages(from buddy: User) {
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter("from = \(buddy.userId) || to = \(buddy.userId)")
                .sorted(byKeyPath: "createDate", ascending: false)
            let count = results.count
            guard count > 0 else { return }
            let loopCount = min(20, count)
            for index in 0..<loopCount {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            self.multicastDelegate.invoke({ $0.messengerDidLoadMessages(messages, buddy: buddy) })
        })
    }
    
    func loadMoreMessages(from buddy: User, lastMessage: InstantMessage) {
        guard let user = user else {
            logger.debug("User is nil")
            return
        }
        let limit = 20
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter(
                    NSPredicate(
                        format: "createDate < %@ &&" +
                            " ((from = \(user.userId) && to = \(buddy.userId)) ||" +
                        " (from = \(buddy.userId) && to = \(user.userId)))",
                        lastMessage.createDate as CVarArg
                    )
                )
                .sorted(byKeyPath: "createDate", ascending: false)
            let count = min(results.count, limit)
            guard count > 0 else { return }
            for index in 0..<count {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            if messages.isEmpty {
                if let remoteID = lastMessage.remoteID {
                    self.fetchMoreMessages(from: buddy, remoteID: remoteID)
                } else {
                    self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], buddy: buddy)})
                }
            } else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, buddy: buddy)})
            }
        })
    }
    
    private func fetchMoreMessages(from buddy: User, remoteID: UInt64) {
        logger.debug()
        var request = DirectionGetReq()
        request.from = buddy.userId
        request.msgID = remoteID
        request.count = 20
        request.direction = .up
        send(request, responseType: DirectionGetResp.self) { (response) in
            guard let response = response else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], buddy: buddy) })
                return
            }
            let messages = response.msgList.map(InstantMessage.init(proto:))
            self.saveMessages(messages, update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, buddy: buddy)})
            })
        }
    }
    
    // MARK: - Conversations
    
    func loadConversations() {
        guard let userID = user?.userId, state == .online else { return }
        var request = RecentGetReq()
        request.from = userID
        send(request, responseType: RecentGetResp.self) { (response) in
            guard let response = response else { return }
            self.saveMessages(response.msgList.map(InstantMessage.init(proto:)), update: false)
        }
    }
    
    func loadLocalConversations() {
        var conversations = [Conversation]()
        storage?.read({ (realm) in
            realm.objects(ConversationData.self).forEach({ (result) in
                if let conversation = Conversation(data: result) {
                    conversations.append(conversation)
                }
            })
        }, callback: {
            logger.debug(conversations.count)
            self.updateUnreadCount()
            self.multicastDelegate.invoke({ $0.messengerDidUpdateConversations(conversations) })
        })
    }
    
    func removeConversation(userID: UInt64) {
        storage?.write({ (realm) in
            if let conversation = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(userID)) {
                realm.delete(conversation)
            }
            let results = realm.objects(InstantMessageData.self).filter("from = \(userID) || to = \(userID)")
            realm.delete(results)
        }, callback: { _ in
            self.updateUnreadCount()
        })
        web.request(.removeRecentMessage(userID: userID)) { (result) in
            logger.debug(result)
        }
    }
    
    func startConversation(userID: UInt64) {
        conversationUserID = userID
    }
    
    func endConversation(userID: UInt64) {
        conversationUserID = nil
    }
    
    func markConversationAsRead(userID: UInt64) {
        storage?.write({ (realm) in
            let data = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(userID))
            data?.unreadCount = 0
            data?.likesCount = 0
            realm.objects(InstantMessageData.self).filter("from = \(userID) || to = \(userID)")
                .forEach({ $0.isRead = true })
        }, callback: { (_) in
            self.updateUserConversations(with: [userID])
        })
    }
    
    // MARK: - Private
    
    private func getMessages(with IDs: [UInt64], callback: @escaping ([InstantMessage]) -> Void) {
        var request = GetReq()
        request.msgIDList = IDs
        send(request, responseType: GetResp.self) { (response) in
            guard let response = response else { return }
            logger.debug(response)
            let messages: [InstantMessage] = response.msgList.map({ proto in
                var message = InstantMessage(proto: proto)
                if let userID = self.conversationUserID, message.from == userID {
                    message.isRead = true
                }
                return message
            })
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
    
    private func saveMessages(_ messages: [InstantMessage], update: Bool = false, callback: (() -> Void)? = nil) {
        guard let userID = user?.userId else {
            logger.warning("User is nil")
            return
        }
        var userIDs = Set<UInt64>()
        storage?.write({ (realm) in
            var dataArray = [InstantMessageData]()
            messages.forEach({ (message) in
                userIDs.insert(message.from == userID ? message.to : message.from)
                var localMessage: InstantMessageData?
                if let remoteID = message.remoteID, remoteID != 0 {
                    localMessage = realm.objects(InstantMessageData.self).filter("remoteID = \(remoteID)").first
                }
                let newMessage = InstantMessageData.data(with: message)
                if let local = localMessage {
                    if update {
                        newMessage.isRead = local.isRead
                        if newMessage.isSent == false {
                            newMessage.isSent = local.isSent
                        }
                        newMessage.localID = local.localID
                        dataArray.append(newMessage)
                    }
                } else {
                    dataArray.append(newMessage)
                }
            })
            realm.add(dataArray, update: true)
        }, callback: { (_) in
            self.updateUserConversations(with: Array(userIDs))
            callback?()
        })
    }
    
    private func updateUserConversations(with userIDs: [UInt64]) {
        guard userIDs.isNotEmpty, let myID = user?.userId else { return }
        var conversations = [Conversation]()
        var userIDsNotSaved = [UInt64]()
        storage?.write({ (realm) in
            userIDs.forEach({ (userID) in
                guard userID != myID else { return }
                guard let userData = realm.object(ofType: UserData.self, forPrimaryKey: Int64(userID)) else {
                    userIDsNotSaved.append(userID)
                    return
                }
                let messages = realm
                    .objects(InstantMessageData.self)
                    .filter("from = \(userID) || to = \(userID)")
                    .sorted(byKeyPath: "sentDate")
                guard let lastMessage = messages.last else {
                    logger.debug("Messages Not Found For Buddy \(userID)")
                    return
                }
                let conversationData: ConversationData
                let unreadCount =
                    messages.filter("isRead = false && from != \(myID) && type != \(IMType.like.rawValue)").count
                let likesCount =
                    messages.filter("isRead = false && from != \(myID) && type == \(IMType.like.rawValue)").count
                if let data = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(userID)) {
                    conversationData = data
                } else {
                    conversationData = ConversationData()
                    conversationData.userID = userData.userID
                    conversationData.user = userData
                }
                conversationData.unreadCount = unreadCount
                conversationData.likesCount = likesCount
                conversationData.lastMessage = lastMessage
                conversationData.date = lastMessage.sentDate
                realm.add(conversationData, update: true)
            })
            let results = realm.objects(ConversationData.self)
            for result in results {
                if let conversation = Conversation(data: result) {
                    conversations.append(conversation)
                }
            }
        }, callback: { _ in
            if userIDsNotSaved.isNotEmpty {
                self.getUserInfoList(with: userIDsNotSaved, callback: { (users) in
                    self.updateUserConversations(with: users.map({ $0.userId }))
                })
            }
            self.updateUnreadCount()
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
                    self.updateActiveStatus()
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
    
    private var deliverQueues = [Int: OperationQueue]()
    
    private func getDeliverQueue(forModule module: Int, command: Int) -> OperationQueue {
        let key = (module << 16) | command
        if let queue = deliverQueues[key] {
            return queue
        }
        let queue = OperationQueue()
        queue.maxConcurrentOperationCount = 1
        deliverQueues[key] = queue
        return queue
    }
    
    private func send<T, R> (
        _ message: T,
        responseType: R.Type,
        callback: ((R?) -> Void)?) where T: Message & MessageTicket, R: Message {
        let package = ImPackageRawdata()
        package.body = try? message.serializedData()
        if package.body == nil { logger.error("package body is nil") }
        let module = message.module.rawValue
        let command = message.command
        let task = DeliverTask<R>(
            service: service,
            package: package,
            module: module,
            command: command,
            callback: {(_, message) in
                callback?(message)
        })
        getDeliverQueue(forModule: module, command: command).addOperation(task)
    }
    
    private func updateUnreadCount() {
        var unreadLikes = 0
        var unreadMessages = 0
        storage?.read({ (realm) in
            let conversations = realm.objects(ConversationData.self)
            for conversation in conversations {
                unreadLikes += conversation.likesCount
                unreadMessages += conversation.unreadCount
            }
            self.messagesUnreadCount = unreadMessages
        }, callback: {
            self.multicastDelegate.invoke({
                $0.messengerDidUpdateUnreadCount(
                    messageUnread: self.messagesUnreadCount ?? 0,
                    likesUnread: unreadLikes
                )
            })
        })
    }
    
    @objc private func syncBadgeNumber() {
        guard let count = messagesUnreadCount else { return }
        var request = BadgeSyncReq()
        request.count = UInt32(count)
        send(request, responseType: BadgeSyncResp.self, callback: nil)
        UIApplication.shared.applicationIconBadgeNumber = count
    }
}

