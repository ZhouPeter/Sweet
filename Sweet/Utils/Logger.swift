//
//  Logger.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

let logger = SimpleLogger.sharedInstance

class SimpleLogger {
    enum Level: Int {
        case none
        case error
        case warning
        case info
        case debug
        case verbose
        
        func tag() -> String {
            switch self {
            case .error:
                return "🚫"
            case .warning:
                return "⚠️"
            case .info:
                return "🎯"
            case .debug:
                return "🚦"
            case .verbose:
                return ""
            case .none:
                return ""
            }
        }
    }
    
    static let sharedInstance = SimpleLogger()
    
    var level: Level = {
        #if DEBUG
        return .verbose
        #else
        return .none
        #endif
    } ()
    
    private init() { }
    
    func isEnabledFor(level: Level) -> Bool {
        return level.rawValue <= self.level.rawValue
    }
    
    func error(_ items: Any..., path: String = #file, function: String = #function, line: Int = #line) {
        log(level: .error, items: items, path: path, function: function, line: line)
    }
    
    func warning(_ items: Any..., path: String = #file, function: String = #function, line: Int = #line) {
        log(level: .warning, items: items, path: path, function: function, line: line)
    }
    
    func info(_ items: Any..., path: String = #file, function: String = #function, line: Int = #line) {
        log(level: .info, items: items, path: path, function: function, line: line)
    }
    
    func debug(_ items: Any..., path: String = #file, function: String = #function, line: Int = #line) {
        log(level: .debug, items: items, path: path, function: function, line: line)
    }
    
    func verbose(_ items: Any..., path: String = #file, function: String = #function, line: Int = #line) {
        log(level: .verbose, items: items, path: path, function: function, line: line)
    }
    
    private func log(level: Level, items: [Any], path: String, function: String, line: Int) {
        if isEnabledFor(level: level) == false {
            return
        }
        let separator = "\n"
        var message = ""
        for item in items {
            if !message.isEmpty {
                message += separator
            }
            if let itemStr = item as? String {
                message += "  - \(itemStr)"
            } else {
                message += "  - \(String(describing: item))"
            }
        }
        let file = path.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        let str = "[\(formatter.string(from: Date()))]"
            + " \(level.tag()) "
            + "\(file).\(function):\(line)\n\(message)"
        print(str)
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
} ()

