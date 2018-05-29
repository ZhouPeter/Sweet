//
//  MessengerDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol MessengerDelegate: class {
    func messengerDidLogin(userID: UInt64, success: Bool)
    func messengerDidLogout(userID: UInt64)
    func messengerDidUpdate(state: MessengerState)
    
}

extension MessengerDelegate {
    func messengerDidLogin(userID: UInt64, success: Bool) {}
    func messengerDidLogout(userID: UInt64) {}
    func messengerDidUpdate(state: MessengerState) {}
}
