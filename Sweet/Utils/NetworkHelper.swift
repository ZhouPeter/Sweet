//
//  NetworkHelper.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/8/15.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import CoreTelephony
import SwiftyUserDefaults
class NetworkHelper {
    class func networkCheck(viewController: UIViewController) {
        guard Defaults[.isNotFirstLaunch] else {
            Defaults[.isNotFirstLaunch] = true
            return
        }
        let cellularData = CTCellularData()
        cellularData.cellularDataRestrictionDidUpdateNotifier = { state in
            switch state {
            case .restricted:
                let alertController = UIAlertController(title: "已为\"讲真\"关闭无线网络",
                                                        message:"您可以在\"设置\"中为此应用打开网络",
                                                        preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "设置", style: .default, handler: { (_) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        self.openURL(url: url)
                    }
                }))
                alertController.addAction(UIAlertAction(title: "好", style: .cancel, handler: nil))
                viewController.present(alertController, animated: true, completion: nil)
            case .notRestricted: break
            case .restrictedStateUnknown: break
            }
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
