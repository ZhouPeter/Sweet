//
//  CoordinatorFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {
    func makePowerCoordinator(router: Router) -> Coordinator & PowerCoordinatorOutput {
        return PowerCoordinator(with: FlowFactoryImp(), router: router)
    }
    
    func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput {
        return OnboardingCoordinator(with: FlowFactoryImp(), router: router)
    }
    
    func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput {
        return AuthCoordinator(with: FlowFactoryImp(), router: router)
    }
}
