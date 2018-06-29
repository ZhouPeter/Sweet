//
//  CoordinatorFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol CoordinatorFactory {
    func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput
    func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput
    func makePowerCoordinator(router: Router) -> Coordinator & PowerCoordinatorOutput
    func makeMainCoordinator(user: User, token: String) -> (coordinator: Coordinator, toPresent: Presentable?)
    func makeProfileCoordinator(user: User,
                                userID: UInt64,
                                router: Router) -> Coordinator & ProfileCoordinatorOutput
    func makeProfileCoordinator(user: User,
                                userID: UInt64,
                                setTop: SetTop?,
                                router: Router) -> Coordinator & ProfileCoordinatorOutput
    func makeProfileCoordinator(user: User,
                                buddyID: UInt64,
                                navigation: UINavigationController?) -> Coordinator & ProfileCoordinatorOutput
    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        current: Int,
        currentStart: Int,
        isGroup: Bool,
        fromCardId: String?,
        storiesGroup: [[StoryCellViewModel]],
        delegate: StoriesPlayerGroupViewControllerDelegate?) -> Coordinator & StoryPlayerCoordinatorOutput
    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        currentStart: Int,
        fromUserId: UInt64?,
        storiesGroup: [[StoryCellViewModel]],
        delegate: StoriesPlayerGroupViewControllerDelegate?) -> Coordinator & StoryPlayerCoordinatorOutput
    func makeIMCoordinator(user: User, token: String, navigation: UINavigationController?) -> Coordinator
    func makeStoryCoordinator(user: User, navigation: UINavigationController?) -> Coordinator
    func makeDismissableStoryCoordinator(
        user: User,
        topic: String?,
        navigation: UINavigationController?) -> Coordinator & StoryCoodinatorOutput
    func makeCardsCoordinator(user: User, navigation: UINavigationController?) -> Coordinator
    func makeContactsCoordinator(router: Router, token: String, storage: Storage, user: User) -> ContactsCoordinator
    func makeInboxCoordinator(user: User, router: Router, token: String) -> InboxCoordinator
    func makeAllCardsCoordinator(user: User, router: Router) -> AllCardsCoordinator
    func makeSubCardsCoordinator(user: User, router: Router) -> SubCardsCoordinator
}
