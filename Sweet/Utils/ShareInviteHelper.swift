//
//  WXShareInviteHelper.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import TencentOpenAPI
class ShareInviteHelper {
    class func sendWXInviteMessage(scene: WeChatScene) {
        if let url = Defaults[.inviteUrl] {
            let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
            WXApi.sendText(text: text, scene: scene)
        } else {
            web.request(.inviteUrl) { (result) in
                switch result {
                case let .success(response):
                    if let url = response["url"] as? String {
                        let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
                        WXApi.sendText(text: text, scene: scene)
                        Defaults[.inviteUrl] = url
                    }
                case let .failure(error):
                    logger.error(error)
                }
            }
        }
    }
    
    class func sendQQInviteMessage() {
        if let url = Defaults[.inviteUrl] {
            let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
            QQApiInterface.sendText(text: text)
        } else {
            web.request(.inviteUrl) { (result) in
                switch result {
                case let .success(response):
                    if let url = response["url"] as? String {
                        let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
                        QQApiInterface.sendText(text: text)
                        Defaults[.inviteUrl] = url
                    }
                case let .failure(error):
                    logger.error(error)
                }
            }
        }
    }
    
    class func sendWeiboInviteMessage() {
        if let url = Defaults[.inviteUrl] {
            let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
            WeiboSDK.sendText(text: text)
        } else {
            web.request(.inviteUrl) { (result) in
                switch result {
                case let .success(response):
                    if let url = response["url"] as? String {
                        let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
                        WeiboSDK.sendText(text: text)
                        Defaults[.inviteUrl] = url
                    }
                case let .failure(error):
                    logger.error(error)
                }
            }
        }
    }
}
