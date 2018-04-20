//
//  AuthCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol AuthCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

final class AuthCoordinator: BaseCoordinator, AuthCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
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
            self?.showSignUp(model: model)
        }
        authOutput.showLogin = {
            
        }
        router.setRootFlow(authOutput.toPresent())
    }
    private func showSignUp(model: RegisterModel) {
        let universityOutput = factory.makeSignUpUniversityOutput(registerModel: model)
        universityOutput.showSignUpCollege = { [weak self] model in
            self?.showSignUpCollege(model: model)
        }
        router.push(universityOutput)
    }
    
    private func showSignUpCollege(model: RegisterModel) {
        let collegeOutput = factory.makeSignUpCollegeOutput(registerModel: model)
        collegeOutput.showSignUpEnrollment = { [weak self] model in
            self?.showSignUpEnrollment(model: model)
        }
        router.push(collegeOutput)
    }
    
    private func showSignUpEnrollment(model: RegisterModel) {
        let enrollmentOutput = factory.makeSignUpEnrollmentOutput(registerModel: model)
        enrollmentOutput.showSignUpSex = { [weak self] model in
            self?.showSignUpSex(model: model)
        }
        router.push(enrollmentOutput)
    }
    
    private func showSignUpSex(model: RegisterModel) {
        let sexOutput = factory.makeSignUpSexOutput(registerModel: model)
        sexOutput.showSignUpName = { [weak self] model in
            self?.showSignUpName(model: model)
        }
        router.push(sexOutput)
    }
    
    private func showSignUpName(model: RegisterModel) {
        let nameOutput = factory.makeSignUpNameOutput(registerModel: model)
        nameOutput.showSignUpAvatar = { [weak self] model in
            self?.showSignUpAvatar(model: model)
        }
        router.push(nameOutput)
    }
    
    private func showSignUpAvatar(model: RegisterModel) {
        let avatarOutput = factory.makeSignUpAvatarOutput(registerModel: model)
        avatarOutput.showSignUpPhone = { [weak self] model in
            self?.showSignUpPhone(model: model)
        }
        router.push(avatarOutput)
    }
    
    private func showSignUpPhone(model: RegisterModel) {
        let phoneOutput = factory.makeSignUpPhoneOutput(registerModel: model)
        phoneOutput.showSetting = {
            
        }
        router.push(phoneOutput)
    }
    
}
