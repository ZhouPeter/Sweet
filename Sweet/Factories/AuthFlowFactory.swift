//
//  AuthFlowFactory.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol AuthFlowFactory {
    func makeAuthOutput() -> AuthView
    func makeLoginOutput() -> LoginView
    func makeSignUpUniversityOutput(registerModel: RegisterModel) -> SignUpUniversityView
    func makeSignUpCollegeOutput(registerModel: RegisterModel) -> SignUpCollegeView
    func makeSignUpEnrollmentOutput(registerModel: RegisterModel) -> SignUpEnrollmentView
    func makeSignUpSexOutput(registerModel: RegisterModel) -> SignUpSexView
    func makeSignUpNameOutput(registerModel: RegisterModel) -> SignUpNameView
    func makeSignUpAvatarOutput(registerModel: RegisterModel) -> SignUpAvatarView
    func makeSignUpPhoneOutput(registerModel: RegisterModel) -> SignUpPhoneView
}
