//
//  TapticEngine+Extension.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/22.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import TapticEngine

extension UIViewController {
    func vibrateFeedback() {
        if traitCollection.forceTouchCapability == .available  {
            TapticEngine.notification.feedback(.success)
        } else {
//            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)
        }
    }
}
