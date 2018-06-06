//
//  WXApi+Message.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
enum WeChatScene: Int32 {
    case conversation = 0
    case timeline = 1
    case favourite = 2
}
extension WXApi {
    @discardableResult class func sendImage(image: UIImage, scene: WeChatScene) -> Bool {
        let message = WXMediaMessage()
        let imageWidth: CGFloat = 50
        let thumbnailSize = CGSize(width: imageWidth, height: image.size.height / image.size.width * imageWidth)
        let thumbImage = image.reSize(newSize: thumbnailSize, interpolationQuality: .medium)
        message.setThumbImage(thumbImage)
        let obj = WXImageObject()
        obj.imageData = UIImageJPEGRepresentation(image, 0.7)
        message.mediaObject = obj
        let req = SendMessageToWXReq()
        req.bText = false
        req.message = message
        req.scene = scene.rawValue
        return WXApi.send(req)
    }
    
    @discardableResult class func sendText(text: String, scene: WeChatScene) -> Bool {
        let req = SendMessageToWXReq()
        req.bText = true
        req.text = text
        req.scene = scene.rawValue
        return WXApi.send(req)
    }
}
