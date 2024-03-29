//
//  ContactsFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol ContactsFlowFactory {
    func makeContactsView() -> ContactsView
    func makeInviteOutput() -> InviteView
    func makeBlackOutput() -> BlackView
    func makeSearchOutput() -> ContactSearchView
}
