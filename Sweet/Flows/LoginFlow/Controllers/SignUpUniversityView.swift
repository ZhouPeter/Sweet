//
//  SignUpUniversityView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
protocol SignUpUniversityView: BaseView {
    var showSignUpCollege: ((RegisterModel) -> Void)? { get set }
}
