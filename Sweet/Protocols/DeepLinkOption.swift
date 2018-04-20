//
//  DeepLinkOption.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

struct DeepLinkURLConstants {
    static let Onboarding = "onboarding"
    static let Login = "login"
    static let SignUp = "signUp"
    static let Setting = "Setting"
}

enum DeepLinkOption {
    case onboarding
    case login
    case signUp
    case setting
    static func build(with dict: [String : AnyObject]?) -> DeepLinkOption? {
        guard let id = dict?["launch_id"] as? String else { return nil }
        
        let itemID = dict?["item_id"] as? String
        
        switch id {
        case DeepLinkURLConstants.Onboarding: return .onboarding
        case DeepLinkURLConstants.Login: return .login
        case DeepLinkURLConstants.SignUp: return .signUp
        default: return nil
        }
    }
}
