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
    static let review = DefaultsKey<Int>("review")
    static let isPersonalStoryChecked = DefaultsKey<Bool>("isPersonalStoryChecked")
}

// Guide
extension DefaultsKeys {
    static let isStoryRecordGuideShown = DefaultsKey<Bool>("isStoryRecordGuideShown")
    static let isTextStoryGuideShown = DefaultsKey<Bool>("isTextStoryGuideShown")
    static let isStoryFilterGuideShown = DefaultsKey<Bool>("isStoryFilterGuideShown")
    static let isScrollNavigationGuideShown = DefaultsKey<Bool>("isScrollNavigationGuideShown")
    static let isStoryPlayGuideShown = DefaultsKey<Bool>("isStoryPlayGuideShown")
    static let isSameCardChoiceGuideShown = DefaultsKey<Bool>("isSameCardChoiceGuideShown")
}

