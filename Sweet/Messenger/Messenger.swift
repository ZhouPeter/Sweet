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
            if isNetworkReachable && userID != nil && token != nil {
                connect()
            }
        }
    }
    private var multicastDelegate = MulticastDelegate<MessengerDelegate>()
    private var userID: UInt64?
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
    
    private init() {
        startNetworkReachabilityObserver()
    }
    
    func addDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.addDelegate(delegate)
    }
    
    func removeDelegate(_ delegate: MessengerDelegate) {
        multicastDelegate.removeDelegate(delegate)
    }
    
    func login(with userID: UInt64, token: String) {
        self.userID = userID
        self.token = token
        guard isNetworkReachable else {
            logger.debug("Waiting network")
            return
        }
        connect()
    }
    
    func logout() {
        guard let userID = self.userID else { return }
        self.userID = nil
        token = nil
        state = .offline
        service.stop {
            logger.debug("Service stopped")
            self.multicastDelegate.invoke({ $0.messengerDidLogout(userID: userID) })
        }
    }
    
    @discardableResult func sendText(_ text: String, to: UInt64) -> InstantMessage {
        var message = InstantMessage()
        message.content = text
        message.type = .text
        message.to = to
        send(message)
        return message
    }
    
    func send(_ message: InstantMessage) {
        guard state == .online else {
            multicastDelegate.invoke({ $0.messengerDidSendMessage(message, success: false) })
            return
        }
        let request = message.makeSendRequest()
        send(request, resonseType: SendResp.self, module: .message, command: MsgCmdID.sendReq.rawValue) { (response) in
            guard let response = response, response.resultCode == 0 else {
                self.multicastDelegate.invoke({ $0.messengerDidSendMessage(message, success: false) })
                return
            }
            var messageSent = message
            messageSent.remoteID = response.msgID
            messageSent.sentDate = Date()
            self.serverDate = Date(timeIntervalSince1970: Double(response.timestamp) / 1000)
            self.multicastDelegate.invoke({ $0.messengerDidSendMessage(messageSent, success: true) })
        }
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
        guard let userID = self.userID else {
            logger.debug("userID is nil")
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
                    if let date = date { self.serverDate = date }
                    self.multicastDelegate.invoke({ $0.messengerDidLogin(userID: userID, success: date != nil) })
                })
            })
        }
    }
    
    private func login(_ callback: @escaping (Date?) -> Void) {
        guard let userID = self.userID, let token = self.token else {
            logger.debug("User info is nil")
            callback(nil)
            return
        }
        var message = LoginReq()
        message.userID = userID
        let timestamp = Date().timestamp()
        message.timestamp = timestamp
        message.signature = "timestamp=\(timestamp)&token=\(token)&user_id=\(userID)&secret=\(secret)".md5
        message.token = token
        message.type = .ios
        message.state = .online
        send(message, resonseType: LoginResp.self, module: .login, command: LoginCmdID.req.rawValue) { (response) in
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

    private func send<T> (
        _ message: Message,
        resonseType: T.Type,
        module: ModuleID,
        command: Int,
        callback: @escaping (T?) -> Void) where T: Message {
        HandlerManager.sharedInstance()
            .addHandler(module.rawValue, commandId: command + 1, handler: MessageHandler<T>(callback: callback))
        let package = ImPackageRawdata()
        package.body = try? message.serializedData()
        if package.body == nil { logger.error("package body is nil") }
        service.send(package, moduleId: module.rawValue, commandId: command) { (code) in
            if code.rawValue != 0 {
                logger.debug("message send failed", message)
                callback(nil)
            }
        }
    }
}
