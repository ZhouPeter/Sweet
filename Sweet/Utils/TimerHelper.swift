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
    
    class func timeBeforeInfo(timeInterval: TimeInterval) -> String {
        var timeIntervalWithSize = Int(timeInterval)
        if String(timeIntervalWithSize).count == 13 {
            timeIntervalWithSize /= 1000
        }
        let nowTimeinterval = Date().timeIntervalSince1970
        let timeInt = Int(nowTimeinterval) - timeIntervalWithSize; //时间差
        let week = timeInt / (3600 * 24 * 7)
        let day = timeInt / (3600 * 24)
        let hour = timeInt / 3600
        let minute = timeInt / 60
        let second = timeInt
        if  week > 0 {
            return "\(week)w"
        } else if day > 0 {
            return "\(day)d"
        } else if hour > 0 {
            return "\(hour)h"
        } else if minute > 0 {
            return "\(minute)m"
        } else {
            return "\(second)s"
        }
    }
    
    class func storyTime(timeInterval: TimeInterval) -> (day: String, time: String) {
        var timeInterval = Int(timeInterval)
        if String(timeInterval).count == 13 {
            timeInterval /= 1000
        }
        let nowTimeInterval = Int(Date().timeIntervalSince1970)
        let nowDate = Date(timeIntervalSince1970: TimeInterval(nowTimeInterval))
        let date = Date(timeIntervalSince1970: TimeInterval(timeInterval))
        let gregorian = Calendar(identifier: .gregorian)
        let month = gregorian.component(.month, from: date)
        let day = gregorian.component(.day, from: date)
        let weak = gregorian.component(.weekday, from: date)
        let hour = gregorian.component(.hour, from: date)
        let minute = gregorian.component(.minute, from: date)
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: nowDate)
        let zeroDate = calendar.date(from: components)!
        let beforZeroData = calendar.date(byAdding: .day, value: -1, to: zeroDate)!
        if timeInterval >= Int(beforZeroData.timeIntervalSince1970) {
            if timeInterval >= Int(zeroDate.timeIntervalSince1970) {
                return ("今天", hourTo12h(hour: hour) + "\(minute)")
            } else {
                return ("昨天", hourTo12h(hour: hour) + "\(minute)")
            }
        } else if timeInterval + 7 * 3600 * 24 >= nowTimeInterval {
            return (getWeakString(weak: weak), hourTo12h(hour: hour) + "\(minute)")
        } else {
            return ("\(month)月\(day)日", hourTo12h(hour: hour) + "\(minute)")
        }
    }
    
    class func hourTo12h(hour: Int) -> String {
        if hour == 12 {
            return "下午：\(hour)"
        } else if hour > 12 {
            return "下午：\(hour - 12)"
        } else {
            return "上午: \(hour)"
        }
    }
    
    class func getWeakString(weak: Int) -> String {
        var string = ""
        if weak == 1 {
            string = "星期日"
        } else if weak == 2 {
            string = "星期一"
        } else if weak == 3 {
            string = "星期二"
        } else if weak == 4 {
            string = "星期三"
        } else if weak == 5 {
            string = "星期四"
        } else if weak == 6 {
            string = "星期五"
        } else if weak == 7 {
            string = "星期六"
        }
        return string
    }
}
