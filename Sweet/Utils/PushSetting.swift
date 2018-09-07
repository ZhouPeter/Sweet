//
//  PushSetting.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/9/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
class PushSetting {
    class func pushCheck() {
        guard let setting =  UIApplication.shared.currentUserNotificationSettings else { return }
        guard setting.types == [] else { return }
        if Defaults[.isSettingPush]
            && Defaults[.pushMessageTime] + 2 * 7 * 24 * 60 * 60 < Int(Date().timeIntervalSince1970) {
            let alert = UIAlertController(title: nil,
                                          message: "为了保证可以正常接收讲真联系人消息，建议你开启设置中的通知推送权限。",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "好的", style: .default, handler: { (_) in
                if let url = URL(string: UIApplicationOpenSettingsURLString) {
                    self.openURL(url: url)
                }
            }))
            let rootViewController = UIApplication.shared.keyWindow?.rootViewController
            rootViewController?.present(alert, animated: true, completion: nil)
            Defaults[.pushMessageTime] = Int(Date().timeIntervalSince1970)
        } else {
            let appDelegate  = UIApplication.shared.delegate as? AppDelegate
            appDelegate?.setUserNotificationCenter(completion: {
                Defaults[.isSettingPush] = true
            })
        }
    }
    class func openURL(url: URL) {
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
}
