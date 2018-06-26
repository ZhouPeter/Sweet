//
//  FlowFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//
// swiftlint:disable colon

import Foundation
import Hero
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
    
    func makeSignUpPhoneOutput(loginRequestBody: LoginRequestBody, isLogin: Bool) -> SignUpPhoneView {
        let viewController = SignUpPhoneController(isLogin: isLogin)
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
    
    func makeStoryRecordView(user: User) -> StoryRecordView {
        return StoryRecordController(user: user)
    }
    
    func makeStoryEditView(fileURL: URL, isPhoto: Bool, topic: String?) -> StoryEditView {
        return StoryEditController(fileURL: fileURL, isPhoto: isPhoto, topic: topic)
    }
    
    func makeDismissableStoryRecordView(user: User, topic: String?) -> StoryRecordView {
        return StoryRecordController(user: user, topic: topic, isDismissable: true)
    }
    
    func makeCardsManagerView(user: User) -> CardsManagerView {
        return CardsManagerController(user: user)
    }
    
    func makeProfileView(user: User, userId: UInt64, setTop: SetTop?) -> ProfileView {
        return ProfileController(user: user, userId: userId, setTop: setTop)
    }
    
    func makeTopicListView() -> TopicListView {
        return TopicListController()
    }
    
    func makeStoryTextView(with topic: String?) -> StoryTextView {
        return StoryTextController(topic: topic)
    }
    
    func makeAlbumView() -> AlbumView {
        return AlbumController()
    }
    
    func makePhotoCropView(with photo: UIImage) -> PhotoCropView {
        return PhotoCropController(with: photo)
    }
}
extension FlowFactoryImp: StoryPlayerFlowFactory {
    func makeStoriesPlayerView(user: User,
                               stories: [StoryCellViewModel],
                               current: Int,
                               delegate: StoriesPlayerViewControllerDelegate?) -> StoriesPlayerView {
        let controller = StoriesPlayerViewController(user: user)
        controller.currentIndex = current
        controller.stories = stories
        controller.delegate = delegate
        controller.hero.isEnabled = true
        return controller
    }
    
    func makeStoiesGroupView(user: User,
                             storiesGroup: [[StoryCellViewModel]],
                             currentIndex: Int,
                             currentStart: Int,
                             fromCardId: String?,
                             delegate: StoriesPlayerGroupViewControllerDelegate?) -> StoriesGroupView {
        let controller = StoriesPlayerGroupViewController(
            user: user,
            storiesGroup: storiesGroup,
            currentIndex: currentIndex,
            currentStart: currentStart,
            fromCardId: fromCardId)
        controller.delegate = delegate
        return controller
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
