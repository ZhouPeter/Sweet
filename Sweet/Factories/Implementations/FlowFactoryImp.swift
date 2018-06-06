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
    
    func makeStoryEditView(fileURL: URL, isPhoto: Bool, topic: String?) -> StoryEditView {
        return StoryEditController(fileURL: fileURL, isPhoto: isPhoto, topic: topic)
    }
    
    func makeCardsManagerView() -> CardsManagerView {
        return CardsManagerController()
    }
    
    func makeProfileView(user: User, userId: UInt64) -> ProfileView {
        return ProfileController(user: user, userId: userId)
    }
    
    func makeTopicListView() -> TopicListView {
        return TopicListController()
    }
    
    func makeStoryTextView() -> StoryTextView {
        return StoryTextController()
    }
    
    func makeAlbumView() -> AlbumView {
        return AlbumController()
    }
    
    func makePhotoCropView(with photo: UIImage) -> PhotoCropView {
        return PhotoCropController(with: photo)
    }
}

extension FlowFactoryImp: IMFlowFactory {
    func makeContactSearchOutput() -> ContactSearchView {
        return ContactSearchController()
    }
    
    func makeIMView() -> IMView {
        return IMController()
    }
}

extension FlowFactoryImp: ContactsFlowFactory {
    func makeContactsView() -> ContactsView {
        return ContactsController()
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
    
 
}
