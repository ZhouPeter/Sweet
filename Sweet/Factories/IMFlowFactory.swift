//
//  IMFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol IMFlowFactory {
    func makeIMManagerView() -> IMManagerView
    func makeIMListView() -> IMListView
    func makeInviteOutput() -> InviteView
    func makeBlackOutput() -> BlackView
    func makeBlockOutput() -> BlockView
    func makeSubscriptionOutput() -> SubscriptionView
    func makeProfileOutput(userId: UInt64) -> ProfileView
}
