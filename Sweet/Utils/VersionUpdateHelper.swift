//
//  VersionUpdateHelper.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
enum VersionUpdateType: UInt {
    case none
    case update
    case mustUpdate
}
class VersionUpdateHelper {
    typealias UpdateCompletionType = (VersionUpdateType, String?, String?, String?) -> Void
    private class func getVersion(completion: @escaping UpdateCompletionType) {
        web.request(WebAPI.getVersion) { (result) in
            switch result {
            case .failure(let error):
                logger.debug(error)
            case .success(let response):
                guard let info = Bundle.main.infoDictionary,
                      let currentVersionString = info["CFBundleShortVersionString"] as? String,
                      let appVersion = response["appVersion"] as? [String: Any],
                      let minVersionString = appVersion["minVersion"] as? String,
                      let newVersionString = appVersion["version"] as? String else { return }
                let currentVersion = getVersionInteger(version: currentVersionString)
                let minVersion = getVersionInteger(version: minVersionString)
                let newVersion = getVersionInteger(version: newVersionString)
                if currentVersion < minVersion {
                    if let content = appVersion["content"] as? String, let url = appVersion["url"] as? String {
                        completion(.mustUpdate, newVersionString, content, url)
                    }
                } else if currentVersion < newVersion {
                    if getUpdateTime(version: newVersion) < 1 {
                        setUpdateTime(version: newVersion)
                        if let content = appVersion["content"] as? String, let url = appVersion["url"] as? String {
                            completion(.update, newVersionString, content, url)
                        }
                    }
                } else {
                    completion(.none, nil, nil, nil)
                }
            }
        }
    }
    @objc private class func getVersionInteger(version: String) -> Int {
        let versionString = version.replacingOccurrences(of: ".", with: "")
        let versionInt  = Int(versionString)! *
                          Int(NSDecimalNumber(decimal: pow(10, 4 - versionString.count)).doubleValue)
        return versionInt
    }
    
    private class func getUpdateTime(version: Int) -> Int {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: Date())
        let versionTimeKey = DefaultsKey<Int>("\(version)\(dateString)UpdateVersion")
        return Defaults[versionTimeKey]
    }
    
    private class func setUpdateTime(version: Int) {
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd"
        let dateString = df.string(from: Date())
        let versionTimeKey = DefaultsKey<Int>("\(version)\(dateString)UpdateVersion")
        let oldTime = getUpdateTime(version: version)
        if oldTime == 1 { return }
        Defaults[versionTimeKey] = oldTime + 1
    }
    private class func appStore(urlString: String?) {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                if UIApplication.shared.canOpenURL(url) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }
    
    class func versionCheck(viewController: UIViewController) {
        self.getVersion { (updateType, newVersion, content, url) in
            if updateType == .mustUpdate {
                let alertController = UIAlertController(title: "【讲真\(newVersion!)】版本更新",
                                                        message: content,
                                                        preferredStyle: .alert)
                let updateAction = UIAlertAction(title: "立即更新", style: .default, handler: { (_) in
                    self.appStore(urlString: url)
                })
                let subView1 = alertController.view.subviews[0]
                let subView2 = subView1.subviews[0]
                let subView3 = subView2.subviews[0]
                let subView4 = subView3.subviews[0]
                let subView5 = subView4.subviews[0]
                if let message = subView5.subviews[1] as? UILabel {
                    message.textAlignment = .left
                }
                alertController.addAction(updateAction)
                alertController.preferredAction = updateAction
                viewController.present(alertController, animated: true, completion: nil)
            } else if updateType == .update {
                let alertController = UIAlertController(title: "【讲真\(newVersion!)】版本更新",
                                                        message: content,
                                                        preferredStyle: .alert)
                let updateAction = UIAlertAction(title: "立即更新", style: .default, handler: { (_) in
                    self.appStore(urlString: url)

                })
                let subView1 = alertController.view.subviews[0]
                let subView2 = subView1.subviews[0]
                let subView3 = subView2.subviews[0]
                let subView4 = subView3.subviews[0]
                let subView5 = subView4.subviews[0]
                if let message = subView5.subviews[1] as? UILabel {
                    message.textAlignment = .left
                }
                alertController.addAction(updateAction)
                alertController.addAction(UIAlertAction(title: "暂不", style: .cancel, handler: nil))
                alertController.preferredAction = updateAction
                viewController.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
