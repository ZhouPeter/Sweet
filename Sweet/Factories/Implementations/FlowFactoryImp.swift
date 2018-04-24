//
//  FlowFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

final class FlowFactoryImp: OnboardingFlowFactory, AuthFlowFactory, IMFlowFactory, StoryFlowFactory, CardsFlowFactory {
    func makeSignUpPhoneOutput(registerModel: RegisterModel) -> SignUpPhoneView {
        let viewController = SignUpPhoneController()
        viewController.registeModel = registerModel
        return viewController
    }
    
    func makeSignUpAvatarOutput(registerModel: RegisterModel) -> SignUpAvatarView {
        let viewController = SignUpAvatarController()
        viewController.registerModel = registerModel
        return viewController
    }
    
    func makeSignUpNameOutput(registerModel: RegisterModel) -> SignUpNameView {
        let viewController = SignUpNameController()
        viewController.registerModel = registerModel
        return viewController
    }
    
    func makeSignUpSexOutput(registerModel: RegisterModel) -> SignUpSexView {
        let viewController = SignUpSexController()
        viewController.registerModel = registerModel
        return viewController
    }

    func makeSignUpEnrollmentOutput(registerModel: RegisterModel) -> SignUpEnrollmentView {
        let viewController = SignUpEnrollmentController()
        viewController.registerModel = registerModel
        return viewController
    }
    
    func makeLoginOutput() -> LoginView {
        return LoginController()
    }
    
    func makeSignUpUniversityOutput(registerModel: RegisterModel) -> SignUpUniversityView {
        let viewController = SignUpUniversityController()
        viewController.registerModel = registerModel
        return viewController
    }
    
    func makeSignUpCollegeOutput(registerModel: RegisterModel) -> SignUpCollegeView {
        let viewController = SignUpCollegeController()
        viewController.registerModel = registerModel
        return viewController
    }
    
    func makeOnboardingFlow() -> OnboardingView {
        return OnboardingController()
    }
    
    func makeAuthOutput() -> AuthView {
        return AuthViewController()
    }
    
    func makeIMListView() -> IMListView {
        return IMListController()
    }
    
    func makeStoryRecordView() -> StoryRecordView {
        return StoryRecordController()
    }
    
    func makeCardsView() -> CardsView {
        return CardsController()
    }
}
