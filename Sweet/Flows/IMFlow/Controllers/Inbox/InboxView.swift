//
//  InboxView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol InboxView: BaseView {
    var showProfile: (() -> Void)? { get set }
    func didUpdateAvatar(URLString: String)
    func didShow()
}
