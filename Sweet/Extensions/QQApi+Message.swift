//
//  QQApi+Extension.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import TencentOpenAPI
enum QQScene: Int32 {
    case QQ = 0
    case QZone = 1
}
extension QQApiInterface {
    @discardableResult class func sendText(text: String, isCallLog: Bool = true) -> QQApiSendResultCode {
        let txtObj = QQApiTextObject(text: text)
        let req =  SendMessageToQQReq(content: txtObj)
        if isCallLog { web.request(.interfaceCallLog(type: 3)) { (_) in } }
        req?.type = Int32(ESENDMESSAGETOQQREQTYPE.rawValue)
        return QQApiInterface.send(req)
    }
}
