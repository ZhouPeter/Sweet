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
    func makeSignUpUniversityOutput(loginRequestBody: LoginRequestBody) -> SignUpUniversityView
    func makeSignUpCollegeOutput(loginRequestBody: LoginRequestBody) -> SignUpCollegeView
    func makeSignUpEnrollmentOutput(loginRequestBody: LoginRequestBody) -> SignUpEnrollmentView
    func makeSignUpSexOutput(loginRequestBody: LoginRequestBody) -> SignUpSexView
    func makeSignUpNameOutput(loginRequestBody: LoginRequestBody) -> SignUpNameView
    func makeSignUpAvatarOutput(loginRequestBody: LoginRequestBody) -> SignUpAvatarView
    func makeSignUpPhoneOutput(loginRequestBody: LoginRequestBody, isLogin: Bool) -> SignUpPhoneView
}
