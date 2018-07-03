//
//  CGRect+RawRepresentable.swift
//  Sweet
//
//  Created by Mario Z. on 2018/7/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

extension CGRect: RawRepresentable {
    public typealias RawValue = String
    
    public var rawValue: String {
        return "(\(origin.x), \(origin.y), \(size.width), \(size.height))"
    }
    
    public init?(rawValue: String) {
        let string = rawValue.trimmingCharacters(in: CharacterSet(charactersIn: "()"))
        let elements = string.components(separatedBy: ",")
        guard elements.count == 4 else { return nil }
        let formatter = NumberFormatter()
        guard
            let x = formatter.number(from: elements[0])?.doubleValue,
            let y = formatter.number(from: elements[1])?.doubleValue,
            let width = formatter.number(from: elements[2])?.doubleValue,
            let height = formatter.number(from: elements[3])?.doubleValue
            else {
                return nil
        }
        self.init(x: x, y: y, width: width, height: height)
    }
}
