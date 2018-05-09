//
//  FlowFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable colon

import Foundation

final class FlowFactoryImp:
    OnboardingFlowFactory,
    AuthFlowFactory,
    StoryFlowFactory,
    CardsFlowFactory,
    PowerFlowFactory,
ProfileFlowFactory {

    func makeProfileUpdateOutput(user: UserResponse) -> UpdateView {
        let viewController = UpdateController()
        viewController.user = user
        return viewController
    }
    
    func makeProfileAboutOutput(user: UserResponse) -> AboutView {
        let viewController = AboutController()
        viewController.user = user
        return viewController
    }

    func makePowerPushOutput() -> PowerPushView {
        return PowerPushController()
    }
    func makePowerContactsOutput() -> PowerContactsView {
        return PowerContactsController()
    }
    
    func makeSignUpPhoneOutput(loginRequestBody: LoginRequestBody) -> SignUpPhoneView {
        let viewController = SignUpPhoneController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeSignUpAvatarOutput(loginRequestBody: LoginRequestBody) -> SignUpAvatarView {
        let viewController = SignUpAvatarController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeSignUpNameOutput(loginRequestBody: LoginRequestBody) -> SignUpNameView {
        let viewController = SignUpNameController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeSignUpSexOutput(loginRequestBody: LoginRequestBody) -> SignUpSexView {
        let viewController = SignUpSexController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }

    func makeSignUpEnrollmentOutput(loginRequestBody: LoginRequestBody) -> SignUpEnrollmentView {
        let viewController = SignUpEnrollmentController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeSignUpUniversityOutput(loginRequestBody: LoginRequestBody) -> SignUpUniversityView {
        let viewController = SignUpUniversityController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeSignUpCollegeOutput(loginRequestBody: LoginRequestBody) -> SignUpCollegeView {
        let viewController = SignUpCollegeController()
        viewController.loginRequestBody = loginRequestBody
        return viewController
    }
    
    func makeOnboardingModule() -> OnboardingView {
        return OnboardingController()
    }
    func makeAuthOutput() -> AuthView {
        return AuthViewController()
    }
    
    func makeStoryRecordView() -> StoryRecordView {
        return StoryRecordController()
    }
    
    func makeCardsView() -> CardsView {
        return CardsController()
    }
    
    func makeProfileModule() -> ProfileView {
        return ProfileController()
    }
}

extension FlowFactoryImp: IMFlowFactory {
    func makeIMManagerView() -> IMManagerView {
        return IMManagerController()
    }
    func makeIMListView() -> IMListView {
        return IMListController()
    }
    func makeInviteOutput() -> InviteView {
        return InviteController()
    }
    func makeBlackOutput() -> BlackView {
        return BlackController()
    }
    func makeBlockOutput() -> BlockView {
        return BlockController()
    }
    func makeSubscriptionOutput() -> SubscriptionView {
        return SubscriptionController()
    }
    func makeProfileOutput(userId: UInt64) -> ProfileView {
        let controller = ProfileController()
        controller.userId = userId
        return controller
    }
    
    
}
