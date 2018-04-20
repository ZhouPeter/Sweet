//
//  AuthView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol AuthView: BaseView {
    var showSignUp: ((RegisterModel) -> Void)? { get set }
    var showLogin: (() -> Void)? { get set }
}
