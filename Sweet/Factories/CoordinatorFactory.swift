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
    func makeProfileCoordinator(user: User, userID: UInt64, router: Router) -> Coordinator & ProfileCoordinatorOutput
    func makeIMCoordinator(user: User, token: String, navigation: UINavigationController?) -> Coordinator
    func makeStoryCoordinator(user: User, navigation: UINavigationController?) -> Coordinator
    func makeCardsCoordinator(user: User, navigation: UINavigationController?) -> Coordinator
    func makeContactsCoordinator(router: Router, token: String, storage: Storage, user: User) -> ContactsCoordinator
    func makeInboxCoordinator(user: User, router: Router, token: String) -> InboxCoordinator
}
