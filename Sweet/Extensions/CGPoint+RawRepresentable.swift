//
//  CGPoint+RawRepresentable.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension CGPoint: RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String {
        return "(\(x), \(y)"
    }
    
    public init?(rawValue: String) {
        let string = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        let elements = string.components(separatedBy: ",")
        guard elements.count == 2 else { return nil }
        let formatter = NumberFormatter()
        guard
            let x = formatter.number(from: elements[0])?.doubleValue,
            let y = formatter.number(from: elements[1])?.doubleValue
            else {
                return nil
        }
        self.init(x: x, y: y)
    }
}
