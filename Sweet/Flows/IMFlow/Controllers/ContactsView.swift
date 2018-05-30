//
//  ContactView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol ContactsView: BaseView {
    var delegate: ContactsViewDelegate? { get set }
}

protocol ContactsViewDelegate: class {
    func contactsShowSubscription()
    func contactsShowBlock()
    func contactsShowInvite()
    func contactsShowBlack()
    func contactsShowProfile(userID: UInt64)
    func contactsShowSearch()
}
