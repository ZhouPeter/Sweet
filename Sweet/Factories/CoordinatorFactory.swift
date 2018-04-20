//
//  CoordinatorFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol CoordinatorFactory {
    func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput
    func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput

}
