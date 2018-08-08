//
//  DeepLinkOption.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct DeepLinkURLConstants {
    static let onboarding = "onboarding"
    static let login = "login"
    static let signUp = "signUp"
    static let power = "power"
    static let present = "present"
    static let message = "message"
}

enum DeepLinkOption {
    case onboarding
    case login
    case signUp
    case power
    case present
    case message
    
    static func build(with dict: [String: AnyObject]?) -> DeepLinkOption? {
        guard let id = dict?["launch_id"] as? String else { return nil }
        switch id {
        case DeepLinkURLConstants.onboarding: return .onboarding
        case DeepLinkURLConstants.login: return .login
        case DeepLinkURLConstants.signUp: return .signUp
        case DeepLinkURLConstants.message: return .message
        default: return nil
        }
    }
}
