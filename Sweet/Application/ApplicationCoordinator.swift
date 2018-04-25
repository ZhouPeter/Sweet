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
/// 是否登录授权
private var isAuthorized: Bool = {
    return web.tokenSource.token != nil
}()

final class ApplicationCoordinator: BaseCoordinator {
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private var storage: Storage?
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
    init(router: Router, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.coordinatorFactory = coordinatorFactory
        
        self.storage = Storage(userID: 123)
        
    }
    
    override func start(with option: DeepLinkOption?) {
//        Defaults[.token]  = "234567890-"
//        logger.debug(Defaults[.token])
//
//        if let storage = storage {
//            let user = storage.realm.object(ofType: User.self, forPrimaryKey: 123)
//            logger.debug(user)
//        }
//
//        var newUser: User?
//        storage?.write({ (realm) in
//            let user = User()
//            user.userID = 123
//            user.avatarURLString = "http://a.img"
//            user.college = "wehklj"
//            realm.add(user, update: true)
//        }, callback: { (success) in
//            logger.debug(success)
//            self.storage?.read({ (realm) in
//                if let user = realm.object(ofType: User.self, forPrimaryKey: 123) {
//                    newUser = User(value: user)
//                }
//            }, callback: {
//                logger.debug(newUser)
//            })
//        })
        
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
            case .main:
                runMainFlow()
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
            isAuthorized = true
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
    
    private func runMainFlow() {
        logger.debug()
        let (coordinator, flow) = coordinatorFactory.makeMainCoordinator()
        addDependency(coordinator)
        router.setRootFlow(flow)
        coordinator.start()
    }
}

private enum LaunchInstructor {
    case main, auth, onboarding
    
    static func configure(tutorialWasShown: Bool = onboardingWasShown,
                          isAuthorized: Bool = isAuthorized) -> LaunchInstructor {
        switch (tutorialWasShown, isAuthorized) {
        case (false, _):
            return .onboarding
        case (true, false):
            return .auth
        case (true, true):
            return .main
        }
    }
}
