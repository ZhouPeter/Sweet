//
//  Comparable+Clamp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/8/1.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation

extension Comparable {
    func clamped(to range: ClosedRange<Self>) -> Self {
        if self > range.upperBound {
            return range.upperBound
        } else if self < range.lowerBound {
            return range.lowerBound
        } else {
            return self
        }
    }
}
