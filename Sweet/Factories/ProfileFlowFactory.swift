//
//  ProfileFlowFactory.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol ProfileFlowFactory {
    func makeProfileModule() -> ProfileView
    func makeProfileAboutOutput(user: UserResponse) -> AboutView
    func makeProfileUpdateOutput(user: UserResponse) -> UpdateView
}
