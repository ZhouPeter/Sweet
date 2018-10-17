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
    static let isNotFirstLaunch = DefaultsKey<Bool>("isNotFirstLaunch")
    static let isSettingPush = DefaultsKey<Bool>("isSettingPush")
    static let pushMessageTime = DefaultsKey<Int>("pushMessageTime")
}

// Guide
extension DefaultsKeys {
    static let isStoryRecordGuideShown = DefaultsKey<Bool>("isStoryRecordGuideShown")
    static let isTextStoryGuideShown = DefaultsKey<Bool>("isTextStoryGuideShown")
    static let isStoryFilterGuideShown = DefaultsKey<Bool>("isStoryFilterGuideShown")
    static let isScrollNavigationGuideShown = DefaultsKey<Bool>("isScrollNavigationGuideShown")
    static let isStoryPlayGuideShown = DefaultsKey<Bool>("isStoryPlayGuideShown")
    static let isStoryTagGuideShown = DefaultsKey<Bool>("isStoryTagGuideShown")
    static let isSameCardChoiceGuideShown = DefaultsKey<Bool>("isSameCardChoiceGuideShown")
    static let isPreferenceGuideShown = DefaultsKey<Bool>("isPreferenceGuideShown")

}
//Toast
extension DefaultsKeys {
    static let isInputTextSendMessage = DefaultsKey<Bool>("isInputTextSendMessage")
    static let isJoinGroupChat = DefaultsKey<Bool>("isJoinGroupChat")
    static let isShowGetStarHelpMessage = DefaultsKey<Bool>("isShowGetStarHelpMessage")

}

