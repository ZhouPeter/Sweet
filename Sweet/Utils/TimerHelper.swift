//
//  Timer.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

class TimerHelper {
    class func countDown(time: Int, countDownBlock: ((Int) -> Void)?, endBlock: (() -> Void)? ) {
        var timeout = time
        let queue = DispatchQueue.global()
        let timer = DispatchSource.makeTimerSource(queue: queue)
        timer.schedule(wallDeadline: .now(), repeating: 1)
        timer.setEventHandler {
            if timeout < 0 {
                timer.cancel()
                DispatchQueue.main.async {
                    endBlock?()
                }
            } else {
                DispatchQueue.main.async {
                    timeout -= 1
                    countDownBlock?(timeout)
                }
            }
        }
        timer.resume()
    }
}
