//
//  Date+Timestamp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/29.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension Date {
    func timestamp(isInMiliseconds: Bool = true) -> UInt64 {
        let interval = timeIntervalSince1970
        if isInMiliseconds {
            return UInt64(interval * 1000)
        }
        return UInt64(interval)
    }
}
