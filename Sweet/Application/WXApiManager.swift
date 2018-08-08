//
//  WXApiManager.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol WXApiManagerDelegate: NSObjectProtocol {
    func managerDidRecvMessageResponse(response: SendMessageToWXResp)
}

extension WXApiManagerDelegate {
    func managerDidRecvMessageResponse(response: SendMessageToWXResp) {}
}
class WXApiManager: NSObject, WXApiDelegate {
    weak var delegate: WXApiManagerDelegate?
    static let shared = WXApiManager()
    private override init() {}
    func onResp(_ resp: BaseResp!) {
        if let resp = resp as? SendMessageToWXResp {
            delegate?.managerDidRecvMessageResponse(response: resp)
        }
    }
}
