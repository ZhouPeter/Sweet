//
//  WeiboSDK+Message.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension WeiboSDK {
    @discardableResult class func sendText(text: String, isCallLog: Bool = true) -> Bool {
        let message = WBMessageObject()
        message.text = text
        if let req = WBSendMessageToWeiboRequest.request(withMessage: message) as? WBSendMessageToWeiboRequest {
            if isCallLog { web.request(.interfaceCallLog(type: 2)) { (_) in } }
            return WeiboSDK.send(req)
        } else {
            return false
        }
    }
}
