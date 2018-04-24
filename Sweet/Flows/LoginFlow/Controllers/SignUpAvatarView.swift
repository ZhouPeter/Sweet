//
//  SignUpAvatarView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/20.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol SignUpAvatarView: BaseView {
    var showSignUpPhone: ((LoginRequestBody) -> Void)? { get set }
}
