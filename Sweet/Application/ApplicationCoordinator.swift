//
//  ApplicationCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults

/// 启动引导是否显示
private var onboardingWasShown: Bool = {
    let def = UserDefaults.standard
    let isOpened = def.bool(forKey: OnboardingController.wasShownKey)
    return isOpened
}()

final class ApplicationCoordinator: BaseCoordinator {
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
    init(router: Router, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start(with option: DeepLinkOption?) {
        if let option = option {
            switch option {
            case .onboarding:
                runOnboardingFlow()
            case .signUp:
                runAuthFlow()
            case .power:
                runPowerFlow()
            default:
                childCoordinators.forEach { $0.start(with: option) }
            }
        } else {
            switch instructor {
            case .onboarding:
                runOnboardingFlow()
            case .auth:
                runAuthFlow()
            case let .main(userID, token):
                runMainFlow(userID: userID, token: token)
            }
        }
    }
    
    private func runOnboardingFlow() {
        logger.debug()
        let coordinator = coordinatorFactory.makeOnboardingCoordinator(router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            guard let `self` = self else { return }
            onboardingWasShown = true
            self.start()
            self.router.dismissFlow()
            self.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func runAuthFlow() {
        logger.debug()
        let coordinator = coordinatorFactory.makeAuthCoordinator(router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] isSettingPower in
            guard let `self` = self else { return }
            isSettingPower ? self.start(with: .power) : self.start()
            self.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func runPowerFlow() {
        let coordinator = coordinatorFactory.makePowerCoordinator(router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            guard let `self` = self else { return }
            self.start()
            self.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    private func runMainFlow(userID: UInt64, token: String) {
        logger.debug()
        let (coordinator, flow) = coordinatorFactory.makeMainCoordinator(userID: userID, token: token)
        addDependency(coordinator)
        router.setRootFlow(flow)
        coordinator.start()
    }
}

private enum LaunchInstructor {
    case main(userID: UInt64, token: String)
    case auth
    case onboarding
    
    static func configure(tutorialWasShown: Bool = onboardingWasShown) -> LaunchInstructor {
        if tutorialWasShown == false {
            return .onboarding
        }
        
        guard let IDString = Defaults[.userID], let userID = UInt64(IDString), let token = Defaults[.token] else {
            return .auth
        }
        return .main(userID: userID, token: token)
    }
}
