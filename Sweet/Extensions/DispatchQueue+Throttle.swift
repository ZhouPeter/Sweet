//
//  DispatchQueue+Throttle.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/27.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import Foundation

private var throttleWorkItems = [AnyHashable: DispatchWorkItem]()
private var lastDebounceCallTimes = [AnyHashable: DispatchTime]()
private let nilContext: AnyHashable = arc4random()

public extension DispatchQueue {
    /**
     - parameters:
     - deadline: The timespan to delay a closure execution
     - context: The context in which the throttle should be executed
     - action: The closure to be executed
     Delays a closure execution and ensures no other executions are made during deadline
     */
    private func throttle(deadline: DispatchTime, context: AnyHashable? = nil, action: @escaping () -> Void) {
        let worker = DispatchWorkItem {
            defer { throttleWorkItems.removeValue(forKey: context ?? nilContext) }
            action()
        }
        
        asyncAfter(deadline: deadline, execute: worker)
        
        throttleWorkItems[context ?? nilContext]?.cancel()
        throttleWorkItems[context ?? nilContext] = worker
    }
    
    /**
     - parameters:
     - interval: The interval in which new calls will be ignored
     - context: The context in which the debounce should be executed
     - action: The closure to be executed
     Executes a closure and ensures no other executions will be made during the interval.
     */
    private func debounce(interval: Double, context: AnyHashable? = nil, action: @escaping () -> Void) {
        if let last = lastDebounceCallTimes[context ?? nilContext], last + interval > .now() {
            return
        }
        
        lastDebounceCallTimes[context ?? nilContext] = .now()
        async(execute: action)
        
        // Cleanup & release context
        throttle(deadline: .now() + interval) {
            lastDebounceCallTimes.removeValue(forKey: context ?? nilContext)
        }
    }
    
    /// 函数限流。第一次执行后，interval 内添加的所有任务将在 .now() + interval 之后执行一次。
    func throttleNext(interval: Double, context: AnyHashable, action: @escaping () -> Void) {
        if let last = lastDebounceCallTimes[context], last + interval > .now() {
            throttle(deadline: .now() + interval, context: context, action: action)
            return
        }
        
        lastDebounceCallTimes[context] = .now()
        async(execute: action)
        
        // Cleanup & release context
        throttle(deadline: .now() + interval, context: arc4random()) {
            lastDebounceCallTimes.removeValue(forKey: context)
        }
    }
}
