//
//  AuthCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol AuthCoordinatorOutput: class {
    var finishFlow: ((_ isSettingPower: Bool) -> Void)? { get set }
}

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {
    var finishFlow: ((Bool) -> Void)?
    
    private let factory: AuthFlowFactory
    private let router: Router
    
    init(with factory: AuthFlowFactory, router: Router) {
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showAuth()
    }
    
    func showAuth() {
        let authOutput = factory.makeAuthOutput()
        authOutput.showSignUp = { [weak self] model in
            self?.showSignUpUniversity(model: model)
        }
        authOutput.showLogin = { [weak self] model in
           self?.showLogin(model: model)
        }
        router.setRootFlow(authOutput.toPresent())
    }
    
    private func showLogin(model: LoginRequestBody) {
        let loginOutput = factory.makeSignUpPhoneOutput(loginRequestBody: model)
        loginOutput.onFinish = { [weak self]  isSettingPower in
            self?.finishFlow?(isSettingPower)
        }
        router.push(loginOutput)
    }
    
    private func showSignUpUniversity(model: LoginRequestBody) {
        let universityOutput = factory.makeSignUpUniversityOutput(loginRequestBody: model)
        universityOutput.showSignUpCollege = { [weak self] model in
            self?.showSignUpCollege(model: model)
        }
        router.push(universityOutput)
    }
    
    private func showSignUpCollege(model: LoginRequestBody) {
        let collegeOutput = factory.makeSignUpCollegeOutput(loginRequestBody: model)
        collegeOutput.showSignUpEnrollment = { [weak self] model in
            self?.showSignUpEnrollment(model: model)
        }
        router.push(collegeOutput)
    }
    
    private func showSignUpEnrollment(model: LoginRequestBody) {
        let enrollmentOutput = factory.makeSignUpEnrollmentOutput(loginRequestBody: model)
        enrollmentOutput.showSignUpSex = { [weak self] model in
            self?.showSignUpSex(model: model)
        }
        router.push(enrollmentOutput)
    }
    
    private func showSignUpSex(model: LoginRequestBody) {
        let sexOutput = factory.makeSignUpSexOutput(loginRequestBody: model)
        sexOutput.showSignUpName = { [weak self] model in
            self?.showSignUpName(model: model)
        }
        router.push(sexOutput)
    }
    
    private func showSignUpName(model: LoginRequestBody) {
        let nameOutput = factory.makeSignUpNameOutput(loginRequestBody: model)
        nameOutput.showSignUpAvatar = { [weak self] model in
            self?.showSignUpAvatar(model: model)
        }
        router.push(nameOutput)
    }
    
    private func showSignUpAvatar(model: LoginRequestBody) {
        let avatarOutput = factory.makeSignUpAvatarOutput(loginRequestBody: model)
        avatarOutput.showSignUpPhone = { [weak self] model in
            self?.showSignUpPhone(model: model)
        }
        router.push(avatarOutput)
    }
    
    private func showSignUpPhone(model: LoginRequestBody) {
        let phoneOutput = factory.makeSignUpPhoneOutput(loginRequestBody: model)
        phoneOutput.onFinish = { [weak self]  isSettingPower in
            self?.finishFlow?(isSettingPower)
        }
        router.push(phoneOutput)
    }
    
}
