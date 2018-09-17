//
//  Logger.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/17.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation
import os

let logger = SimpleLogger.sharedInstance

final class SimpleLogger {
    enum Level: Int {
        case none
        case error
        case debug
        case verbose
        
        var tag: String {
            switch self {
            case .error:
                return "🚫"
            case .debug:
                return "🚦"
            case .verbose:
                return ""
            case .none:
                return ""
            }
        }
        
        var osLogType: OSLogType {
            switch self {
            case .error:
                return .error
            case .debug:
                return .debug
            default:
                return .`default`
            }
        }
    }
    
    static let sharedInstance = SimpleLogger()
    
    var level = Level.verbose
    
    private init() { }
    
    func isEnabledFor(level: Level) -> Bool {
        return level.rawValue <= self.level.rawValue
    }
    
    func error(_ message: @autoclosure () -> Any,
               path: String = #file,
               function: String = #function,
               line: Int = #line) {
        log(message, level: .error, path: path, function: function, line: line)
    }
    
    func debug(_ message: @autoclosure () -> Any,
               path: String = #file,
               function: String = #function,
               line: Int = #line) {
        log(message, level: .debug, path: path, function: function, line: line)
    }
    
    func verbose(_ message: @autoclosure () -> Any,
                 path: String = #file,
                 function: String = #function,
                 line: Int = #line) {
        log(message, level: .verbose, path: path, function: function, line: line)
    }
    
    private func log(_ message: @autoclosure () -> Any,
                     level: Level,
                     path: String,
                     function: String,
                     line: Int) {
        #if DEBUG
        guard isEnabledFor(level: level) else { return }
        let file = path.components(separatedBy: "/").last!.components(separatedBy: ".").first!
        let logMessage = "[\(formatter.string(from: Date()))]"
            + level.tag
            + "\(file).\(function):\(line)\n\(message())"
        print(logMessage)
        #endif
    }
}

private let formatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss.SSS"
    return formatter
} ()
