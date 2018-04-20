//
//  UIViewController+Toast.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import APESuperHUD

extension UIViewController {
    
    func toast(message: String, duration: Double) {
        APESuperHUD.showOrUpdateHUD(icon: .info, message: message, duration: 2, presentingView: view)
    }
  
}
