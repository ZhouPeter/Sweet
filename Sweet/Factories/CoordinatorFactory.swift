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

    func makeMainCoordinator() -> (coordinator: Coordinator, toPresent: Presentable?)
    func makeIMCoordinator(navigation: UINavigationController?) -> Coordinator
    func makeStoryCoordinator(navigation: UINavigationController?) -> Coordinator
    func makeCardsCoordinator(navigation: UINavigationController?) -> Coordinator

    func makePowerCoordinator(router: Router) -> Coordinator & PowerCoordinatorOutput
}
