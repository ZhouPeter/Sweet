//
//  IMView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/31.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol IMView: BaseView {
    var delegate: IMViewDelegate? { get set }
    func updateAvatarImage(withURLString urlString: String)
}

protocol IMViewDelegate: class {
    func imViewDidLoad()
    func imViewDidShowInbox(_ view: InboxView)
    func imViewDidShowContacts(_ view: ContactsView)
    func imViewDidPressAvatarButton()
    func imViewDidPressSearchButton()
}
