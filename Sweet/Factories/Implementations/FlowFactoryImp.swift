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
    
    func makeProfileUpdateOutput(user: UserResponse, updateRemain: UpdateRemainResponse) -> UpdateView {
        let viewController = UpdateController(user: user, updateRemain: updateRemain)
        return viewController
    }
    
    func makeProfileAboutOutput(user: UserResponse, updateRemain: UpdateRemainResponse, setting: UserSetting) -> AboutView {
        let viewController = AboutController(user: user, updateRemain: updateRemain, setting: setting)
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
    
    func makeStoryEditView(
        user: User,
        fileURL: URL,
        isPhoto: Bool,
        source: StoryMediaSource,
        topic: String?) -> StoryEditView {
        return StoryEditController(user: user, fileURL: fileURL, isPhoto: isPhoto, source: source, topic: topic)
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
    
    func makeStoryTextView(with topic: String?, user: User) -> StoryTextView {
        return StoryTextController(user: user, topic: topic)
    }
    
    func makeAlbumView() -> AlbumView {
        return AlbumController()
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
                             fromMessageId: String?,
                             delegate: StoriesPlayerGroupViewControllerDelegate?) -> StoriesGroupView {
        let controller = StoriesPlayerGroupViewController(
            user: user,
            storiesGroup: storiesGroup,
            currentIndex: currentIndex,
            currentStart: currentStart,
            fromCardId: fromCardId,
            fromMessageId: fromMessageId)
        controller.delegate = delegate
        return controller
    }
}

extension FlowFactoryImp: IMFlowFactory {
    func makeIMView() -> IMView {
        return IMController()
    }
}

extension FlowFactoryImp: ContactsFlowFactory {
    func makeSearchOutput() -> ContactSearchView {
        return ContactSearchController()
    }
    
    func makeContactsView() -> ContactsView {
        return ContactsController()
    }
    
    func makeInviteOutput() -> InviteView {
        return InviteController()
    }
    
    func makeBlackOutput() -> BlackView {
        return BlackController()
    }
    
}
