//
//  ProfileFlowFactory.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol ProfileFlowFactory {
    func makeProfileView(user: User, userId: UInt64, setTop: SetTop?) -> ProfileView
    func makeProfileAboutOutput(user: UserResponse, updateRemain: UpdateRemainResponse) -> AboutView
    func makeProfileUpdateOutput(user: UserResponse, updateRemain: UpdateRemainResponse) -> UpdateView
}
