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
    private var currentConversationID: UInt64?
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
            selector: #selector(willEnterForeground),
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
    
    @objc private func willEnterForeground() {
        updateActiveStatus()
        connect()
    }
    
    // MARK: - Delegates
    
    func addDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }
    
    func removeDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }
    
    // MARK: - Login
    
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
        messagesUnreadCount = 0
        guard let user = self.user else { return }
        deliverQueues.values.forEach({ $0.cancelAllOperations() })
        isLogining = false
        self.user = nil
        storage = nil
        token = nil
        state = .offline
        service.stop {
            logger.debug("Service stopped")
            self.multicastDelegate.invoke({ $0.messengerDidLogout(user: user) })
        }
    }
    
    // MARK: - User
    
    func loadUserWith(id: UInt64, isForceSynced: Bool = false, callback: @escaping ((User?) -> Void)) {
        if isForceSynced {
            getUserInfoList(with: [id]) { (users) in
                callback(users.first)
            }
            return
        }
        var buddy: User?
        storage?.read({ (realm) in
            if let result = realm.object(ofType: UserData.self, forPrimaryKey: Int64(id)) {
                buddy = User(data: result)
            }
        }, callback: {
            if buddy == nil {
                self.loadUserWith(id: id, isForceSynced: true, callback: callback)
            } else {
                callback(buddy)
            }
        })
    }
    
    func getUserInfoList(with userIDs: [UInt64], callback: @escaping ([User]) -> Void) {
        var request = UserInfoGetReq()
        request.userIDList = userIDs
        fetch(request, responseType: UserInfoGetResp.self, callback: { response in
            var userList = [User]()
            guard let response = response, response.resultCode == 0 else {
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
    
    // MARK: - Group
    
    func loadGroupWith(id: UInt64, isForceSynced: Bool = false, callback: @escaping ((Group?) -> Void)) {
        if isForceSynced {
            getGroupWith(id: id, callback: callback)
            return
        }
        var group: Group?
        storage?.read({ (realm) in
            if let result = realm.object(ofType: GroupData.self, forPrimaryKey: Int64(id)) {
                group = result.makeGroup()
            }
        }, callback: {
            if group == nil {
                self.loadGroupWith(id: id, isForceSynced: true, callback: callback)
            } else {
                callback(group)
            }
        })
    }
    
    func getGroupWith(id: UInt64, callback: @escaping ((Group?) -> Void)) {
        var request = GroupInfoGetReq()
        request.groupID = id
        fetch(request, responseType: GroupInfoGetResp.self, callback: { (response) in
            guard let response = response, response.resultCode == 0 else {
                callback(nil)
                return
            }
            let group = Group(proto: response.groupInfo)
            self.storage?.write({ (realm) in
                realm.add(GroupData.data(with: group), update: true)
            }, callback: { (_) in
                callback(group)
            })
        })
    }
    
    @objc func updateActiveStatus() {
        guard state == .online else { return }
        var request = ActiveSyncReq()
        request.status = UIApplication.shared.applicationState == .background ? .background : .foreground
        fetch(request, responseType: ActiveSyncResp.self, callback: nil)
    }
    
    // MARK: - Messages
    
    func send(_ message: InstantMessage) {
        saveMessages([message], update: true)
        updateConversationWithSendMessage(message)
        guard state == .online else {
            var msg = message
            msg.isFailed = true
            msg.isSent = false
            saveMessages([msg], update: true)
            updateConversationWithSendMessage(message)
            multicastDelegate.invoke({ $0.messengerDidSendMessage(msg, success: false) })
            return
        }
        
        let handleCallback: (Int, UInt64, Date) -> Void = { resultCode, msgID, date in
            guard resultCode == 0 else {
                var msg = message
                msg.isFailed = true
                msg.isSent = false
                self.saveMessages([msg], update: true)
                self.updateConversationWithSendMessage(msg)
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(msg, success: false) })
                return
            }
            var messageSent = message
            messageSent.remoteID = msgID
            messageSent.sentDate = Date()
            messageSent.isSent = true
            messageSent.isFailed = false
            self.serverDate = date
            self.saveMessages([messageSent], update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(messageSent, success: true) })
            })
            self.updateConversationWithSendMessage(messageSent)
        }
        
        if message.isGroup {
            let request = message.makeGroupMessageSendRequest()
            fetch(request, responseType: GroupMessageSendResp.self) { (response) in
                guard let response = response, response.resultCode == 0 else {
                    handleCallback(-1, 0, Date())
                    return
                }
                handleCallback(Int(response.resultCode), response.msgID, Date())
            }
        } else {
            let request = message.makeSendRequest()
            fetch(request, responseType: SendResp.self) { (response) in
                guard let response = response, response.resultCode == 0 else {
                    handleCallback(-1, 0, Date())
                    return
                }
                handleCallback(Int(response.resultCode),
                               response.msgID,
                               Date(timeIntervalSince1970: Double(response.timestamp) / 1000))
            }
        }
    }
    
    private func updateConversationWithSendMessage(_ message: InstantMessage) {
        guard let myID = user?.userId, message.from == myID else { return }
        storage?.write({ (realm) in
            guard let data = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(message.to)) else { return }
            data.lastMessageContent = message.displayText()
            if let remoteID = message.remoteID {
                data.lastMessageID.value = Int64(remoteID)
            }
            data.lastMessageTimestamp.value = Int64(message.sentDate.timeIntervalSince1970 * 1000)
        }, callback: { (_) in
            self.loadLocalConversations()
        })
    }
    
    // MARK: - Single Messages
    
    func loadMessages(from buddy: User) {
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter("from == \(buddy.userId) || to == \(buddy.userId)")
                .sorted(byKeyPath: "sentDate", ascending: false)
            let count = results.count
            guard count > 0 else { return }
            let loopCount = min(20, count)
            for index in 0..<loopCount {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            if messages.isEmpty {
                self.fetchRecentMessages(from: buddy)
            } else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMessages(messages, buddy: buddy) })
            }
        })
    }
    
    func fetchRecentMessages(from buddy: User) {
        var request = RecentGetReq()
        request.from = buddy.userId
        fetch(request, responseType: RecentGetResp.self) { (response) in
            guard let response = response, response.resultCode == 0 else {
                return
            }
            let messages = response.msgList.map({ proto -> InstantMessage in
                var message = InstantMessage(proto: proto)
                message.isSent = true
                message.isFailed = false
                message.isRead = true
                return message
            })
            self.saveMessages(messages, update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, buddy: buddy)})
            })
        }
    }
    
    func loadMoreMessages(from buddy: User, lastMessage: InstantMessage) {
        guard let user = user else {
            logger.debug("User is nil")
            return
        }
        let limit = 40
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter(
                    NSPredicate(
                        format: "sentDate < %@ &&" +
                            " ((from == \(user.userId) && to == \(buddy.userId)) ||" +
                        " (from == \(buddy.userId) && to == \(user.userId)))",
                        lastMessage.sentDate as CVarArg
                    )
                )
                .sorted(byKeyPath: "sentDate", ascending: false)
            let count = min(results.count, limit)
            guard count > 0 else { return }
            for index in 0..<count {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            if messages.isEmpty {
                if let remoteID = lastMessage.remoteID {
                    self.fetchMoreMessages(from: buddy, lastMessageID: remoteID)
                } else {
                    self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], buddy: buddy)})
                }
            } else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, buddy: buddy)})
            }
        })
    }
    
    private func fetchMoreMessages(from buddy: User, lastMessageID: UInt64) {
        var request = DirectionGetReq()
        request.from = buddy.userId
        request.msgID = lastMessageID
        request.count = 40
        request.direction = .up
        fetch(request, responseType: DirectionGetResp.self) { (response) in
            guard let response = response else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], buddy: buddy) })
                return
            }
            let messages = response.msgList.map({ proto -> InstantMessage in
                var message = InstantMessage(proto: proto)
                message.isSent = true
                message.isFailed = false
                message.isRead = true
                return message
            })
            self.saveMessages(messages, update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, buddy: buddy)})
            })
        }
    }
    
    // MARK: - Group Messages
    
    func loadMessages(from group: Group) {
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter("to == \(group.id)")
                .sorted(byKeyPath: "sentDate", ascending: false)
            let count = results.count
            guard count > 0 else { return }
            let loopCount = min(20, count)
            for index in 0..<loopCount {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            if messages.isEmpty {
                self.fetchRecentMessages(from: group)
            } else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMessages(messages, group: group) })
            }
        })
    }
    
    func fetchRecentMessages(from group: Group) {
        var request = GroupMessageRecentReq()
        request.groupID = group.id
        fetch(request, responseType: GroupMessageRecentResp.self) { (response) in
            guard let response = response, response.resultCode == 0 else {
                return
            }
            let messages = response.msgList.map({ proto -> InstantMessage in
                var message = InstantMessage(proto: proto)
                message.isSent = true
                message.isFailed = false
                message.isRead = true
                return message
            })
            self.saveMessages(messages, update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, group: group)})
            })
        }
    }
    
    func loadMoreMessages(from group: Group, lastMessage: InstantMessage) {
        let limit = 40
        var messages = [InstantMessage]()
        storage?.read({ (realm) in
            let results = realm
                .objects(InstantMessageData.self)
                .filter("to == \(group.id)")
                .filter(NSPredicate(format: "sentDate < %@", lastMessage.sentDate as NSDate))
                .sorted(byKeyPath: "sentDate", ascending: false)
            let count = min(results.count, limit)
            guard count > 0 else { return }
            for index in 0..<count {
                messages.insert(InstantMessage(data: results[index]), at: 0)
            }
        }, callback: {
            if messages.isEmpty {
                if let remoteID = lastMessage.remoteID {
                    self.fetchMoreMessages(from: group, lastMessageID: remoteID)
                } else {
                    self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], group: group)})
                }
            } else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, group: group)})
            }
        })
    }
    
    private func fetchMoreMessages(from group: Group, lastMessageID: UInt64) {
        var request = GroupMessageDirectionReq()
        request.groupID = group.id
        request.msgID = lastMessageID
        request.count = 40
        request.direction = .up
        fetch(request, responseType: GroupMessageDirectionResp.self) { (response) in
            guard let response = response else {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages([], group: group) })
                return
            }
            let messages = response.msgList.map({ proto -> InstantMessage in
                var message = InstantMessage(proto: proto)
                message.isSent = true
                message.isFailed = false
                message.isRead = true
                return message
            })
            self.saveMessages(messages, update: true, callback: {
                self.multicastDelegate.invoke({ $0.messengerDidLoadMoreMessages(messages, group: group)})
            })
        }
    }
    
    // MARK: - Conversations
    
    func loadConversations() {
        guard state == .online else { return }
        fetch(GetConversationsReq(), responseType: GetConversationsResp.self) { (response) in
            guard let response = response, response.list.isNotEmpty else { return }
            self.storage?.write({ (realm) in
                realm.add(response.list.map(ConversationData.data(with:)), update: true)
            }, callback: { (_) in
                self.updateUnreadCount()
                self.multicastDelegate.invoke({ $0.messengerDidUpdateConversations(response.list) })
            })
        }
    }
    
    func loadLocalConversations() {
        var conversations = [IMConversation]()
        storage?.read({ (realm) in
            realm.objects(ConversationData.self)
                .sorted(byKeyPath: "lastMessageTimestamp", ascending: false)
                .forEach({ (result) in
                    conversations.append(result.makeIMConversation())
                })
        }, callback: {
            self.updateUnreadCount()
            self.multicastDelegate.invoke({ $0.messengerDidUpdateConversations(conversations) })
        })
    }
    
    func removeConversation(_ id: UInt64) {
        storage?.write({ (realm) in
            if let conversation = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(id)) {
                realm.delete(conversation)
            }
            let messages = realm.objects(InstantMessageData.self).filter("from == \(id) || to == \(id)")
            realm.delete(messages)
        }, callback: { (_) in
            self.updateUnreadCount()
        })
        // TODO: 从列表中删除
//        web.request(.removeRecentMessage(userID: userID)) { (result) in
//            logger.debug(result)
//        }
    }
    
    func startConversation(_ id: UInt64) {
        currentConversationID = id
    }
    
    func endConversation() {
        currentConversationID = nil
    }
    
    func markConversationAsRead(_ id: UInt64) {
        storage?.write({ (realm) in
            if let data = realm.object(ofType: ConversationData.self, forPrimaryKey: Int64(id)) {
                data.unreadCount = 0
                data.likesCount = 0
            }
            realm.objects(InstantMessageData.self)
                .filter("from == \(id) || to == \(id)")
                .forEach({ $0.isRead = true })
        }, callback: nil)
    }
    
    // MARK: - Private
    
    private func getMessages(with IDs: [UInt64], callback: @escaping ([InstantMessage]) -> Void) {
        guard IDs.isNotEmpty else {
            callback([])
            return
        }
        var request = GetReq()
        request.msgIDList = IDs
        fetch(request, responseType: GetResp.self) { (response) in
            guard let response = response else { return }
            logger.debug(response)
            let messages: [InstantMessage] = response.msgList.map({ proto in
                var message = InstantMessage(proto: proto)
                if let userID = self.currentConversationID, message.from == userID {
                    message.isRead = true
                }
                message.isSent = true
                return message
            })
            self.storage?.write({ (realm) in
                realm.add(messages.map(InstantMessageData.data(with:)), update: true)
            }, callback: { (_) in
                callback(messages)
            })
        }
    }
    
    private func getGroupMessages(with IDs: [UInt64], callback: @escaping ([InstantMessage]) -> Void ) {
        guard IDs.isNotEmpty else {
            callback([])
            return
        }
        var request = GroupMessageGetReq()
        request.msgIDList = IDs
        fetch(request, responseType: GroupMessageGetResp.self) { response in
            guard let response = response else { return }
            logger.debug(response)
            let messages: [InstantMessage] = response.msgList.map({ proto in
                var message = InstantMessage(proto: proto)
                if let userID = self.currentConversationID, message.from == userID {
                    message.isRead = true
                }
                message.isSent = true
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
                self.updateConversations()
                self.multicastDelegate.invoke({ $0.messengerDidReceiveMessage(message) })
            })
        }
        HandlerManager.sharedInstance()
            .addHandler(ModuleID.message.rawValue, commandId: MsgCmdID.notify.rawValue, handler: handler)
    }
    
    private func listenGroupMessageNotify() {
        let handler = MessageHandler<GroupMessageNotify> { note in
            let package = ImPackageRawdata()
            package.body = try? GroupMessageNotifyAck().serializedData()
            self.service.send(
                package,
                moduleId: ModuleID.groupMessage.rawValue,
                commandId: GroupMessageCmdID.groupMessageNotifyAck.rawValue,
                onMessageSend: nil
            )
            logger.debug(note ?? "")
            guard let notify = note else { return }
            self.getGroupMessages(with: [notify.msgID], callback: { (messages) in
                guard let message = messages.first else { return }
                self.updateConversations()
                self.multicastDelegate.invoke({ $0.messengerDidReceiveMessage(message) })
            })
        }
        HandlerManager.sharedInstance()
            .addHandler(ModuleID.groupMessage.rawValue,
                        commandId: GroupMessageCmdID.groupMessageNotify.rawValue,
                        handler: handler)
    }
    
    private func saveMessages(_ messages: [InstantMessage], update: Bool = false, callback: (() -> Void)? = nil) {
        guard let userID = user?.userId else {
            logger.verbose("User is nil")
            return
        }
        var userIDs = Set<UInt64>()
        storage?.write({ (realm) in
            var dataArray = [InstantMessageData]()
            messages.forEach({ (message) in
                userIDs.insert(message.from == userID ? message.to : message.from)
                var localMessage: InstantMessageData?
                if let remoteID = message.remoteID, remoteID != 0 {
                    localMessage = realm.objects(InstantMessageData.self).filter("remoteID == \(remoteID)").first
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
            callback?()
        })
    }
    
    private func updateConversations() {
        guard currentConversationID == nil else { return }
        loadConversations()
    }
    
    private var isLogining = false
    
    private func login(_ callback: @escaping (Date?) -> Void) {
        guard isLogining == false else {
            logger.debug("isLogining")
            return
        }
        guard let user = self.user, let token = self.token else {
            logger.debug("User is nil")
            callback(nil)
            return
        }
        isLogining = true
        var message = LoginReq()
        message.userID = user.userId
        let timestamp = Date().timestamp()
        message.timestamp = timestamp
        message.signature = "timestamp=\(timestamp)&token=\(token)&user_id=\(user.userId)&secret=\(secret)".md5
        message.token = token
        message.type = .ios
        message.state = .online
        fetch(message, responseType: LoginResp.self) { (response) in
            self.isLogining = false
            if let response = response {
                callback(Date(timeIntervalSince1970: Double(response.serverTime) / 1000))
            } else {
                callback(nil)
            }
        }
    }
    
    private func connect(with address: SocketAddress, completion: @escaping () -> Void) {
        if service.isConnected {
            logger.debug("Service already connected")
            completion()
            return
        }
        service.start(address.host, port: address.port, onConnected: {
            logger.debug("Service connected")
            completion()
        }, onClosed: {
            logger.debug("Service closed")
            self.isLogining = false
            self.deliverQueues.values.forEach({ $0.cancelAllOperations() })
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
    
    private func fetch<T, R> (
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
        fetch(request, responseType: BadgeSyncResp.self, callback: nil)
        UIApplication.shared.applicationIconBadgeNumber = count
    }
    
    // MARK: - Connection
    
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
    
    @objc private func connect() {
        guard state != .online else {
            logger.debug("User is already Online")
            return
        }
        guard let user = self.user else {
            logger.debug("user is nil")
            return
        }
        state = .connecting
        web.request(.socketAddress, responseType: Response<SocketAddressResponse>.self) { (result) in
            logger.debug(result)
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
}
