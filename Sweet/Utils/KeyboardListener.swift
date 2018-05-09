//
//  KeyboardListener.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

enum KeyboardEventType {
    case willShow
    case didShow
    case willHide
    case didHide
    case willChangeFrame
    case didChangeFrame
    
    public var notificationName: Notification.Name {
        switch self {
        case .willShow:
            return .UIKeyboardWillShow
        case .didShow:
            return .UIKeyboardDidShow
        case .willHide:
            return .UIKeyboardWillHide
        case .didHide:
            return .UIKeyboardDidHide
        case .willChangeFrame:
            return .UIKeyboardWillChangeFrame
        case .didChangeFrame:
            return .UIKeyboardDidChangeFrame
        }
    }
    
    init?(name: Notification.Name) {
        switch name {
        case .UIKeyboardWillShow:
            self = .willShow
        case .UIKeyboardDidShow:
            self = .didShow
        case .UIKeyboardWillHide:
            self = .willHide
        case .UIKeyboardDidHide:
            self = .didHide
        case .UIKeyboardWillChangeFrame:
            self = .willChangeFrame
        case .UIKeyboardDidChangeFrame:
            self = .didChangeFrame
        default:
            return nil
        }
    }
    
    static func allEventNames() -> [Notification.Name] {
        return [
            KeyboardEventType.willShow,
            KeyboardEventType.didShow,
            KeyboardEventType.willHide,
            KeyboardEventType.didHide,
            KeyboardEventType.willChangeFrame,
            KeyboardEventType.didChangeFrame
            ].map { $0.notificationName }
    }
}

struct KeyboardEvent {
    let type: KeyboardEventType
    let keyboardFrameBegin: CGRect
    let keyboardFrameEnd: CGRect
    let curve: UIViewAnimationCurve
    let duration: TimeInterval
    
    public var options: UIViewAnimationOptions {
        return UIViewAnimationOptions(rawValue: UInt(curve.rawValue << 16))
    }
    
    init?(notification: Notification) {
        guard let userInfo = notification.userInfo else { return nil }
        guard let type = KeyboardEventType(name: notification.name) else { return nil }
        guard let begin = (userInfo[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard let end = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else { return nil }
        guard
            let curveInt = (userInfo[UIKeyboardAnimationCurveUserInfoKey] as? NSNumber)?.intValue,
            let curve = UIViewAnimationCurve(rawValue: curveInt)
            else { return nil }
        guard
            let durationDouble = (userInfo[UIKeyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue
            else { return nil }
        
        self.type = type
        self.keyboardFrameBegin = begin
        self.keyboardFrameEnd = end
        self.curve = curve
        self.duration = TimeInterval(durationDouble)
    }
}

public enum KeyboardState {
    case initial
    case showing
    case shown
    case hiding
    case hidden
    case changing
}

typealias KeyboardEventClosure = ((_ event: KeyboardEvent) -> Void)

final class KeyboardObserver {
    var state = KeyboardState.initial
    var isEnabled = true
    fileprivate var eventClosures = [KeyboardEventClosure]()
    
    deinit {
        eventClosures.removeAll()
        KeyboardEventType.allEventNames().forEach {
            NotificationCenter.default.removeObserver(self, name: $0, object: nil)
        }
    }
    
    init() {
        KeyboardEventType.allEventNames().forEach {
            NotificationCenter.default.addObserver(self, selector: #selector(notified(_:)), name: $0, object: nil)
        }
    }
    
    func observe(_ event: @escaping KeyboardEventClosure) {
        eventClosures.append(event)
    }
}

internal extension KeyboardObserver {
    @objc func notified(_ notification: Notification) {
        guard let event = KeyboardEvent(notification: notification) else { return }
        
        switch event.type {
        case .willShow:
            state = .showing
        case .didShow:
            state = .shown
        case .willHide:
            state = .hiding
        case .didHide:
            state = .hidden
        case .willChangeFrame:
            state = .changing
        case .didChangeFrame:
            state = .shown
        }
        
        if !isEnabled { return }
        eventClosures.forEach { $0(event) }
    }
}
