//
//  Defaults.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import SwiftyUserDefaults

extension DefaultsKeys {
    static let token = DefaultsKey<String?>("token")
    static let userID = DefaultsKey<String?>("userID")
    static let allCardsLastID = DefaultsKey<String?>("allCardsLastID")
    static let subCardsLastID = DefaultsKey<String?>("subCardsLastID")
    static let isEvaluationOthers = DefaultsKey<Bool>("isEvaluationOthers")
    static let isInvited = DefaultsKey<Bool>("isInvited")
    static let inviteUrl = DefaultsKey<String?>("inviteUrl")
}
