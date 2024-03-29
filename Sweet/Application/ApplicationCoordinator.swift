//
//  ApplicationCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import SwiftyUserDefaults
import SDWebImage

/// 启动引导是否显示
private var onboardingWasShown: Bool = {
    let def = UserDefaults.standard
    let isOpened = def.bool(forKey: OnboardingController.wasShownKey)
    return isOpened
} ()

final class ApplicationCoordinator: BaseCoordinator {
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    private var instructor: LaunchInstructor {
        return LaunchInstructor.configure()
    }
    
    init(router: Router, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.coordinatorFactory = coordinatorFactory
        
        SDImageCache.shared.config.maxMemoryCost = 10 * 1024 * 1024
        SDImageCache.shared.config.maxCacheSize = 1000 * 1024 * 1024
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
            case .message:
                if case let .main(user, token) = instructor {
                    runMainFlow(user: user, token: token, isIMFlowSelected: true)
                } else {
                    runAuthFlow()
                }
            default:
                childCoordinators.forEach { $0.start(with: option) }
            }
        } else {
            switch instructor {
            case .onboarding:
                runOnboardingFlow()
            case .auth:
                runAuthFlow()
            case let .main(user, token):
                runMainFlow(user: user, token: token)
                DispatchQueue.global().asyncAfter(deadline: .now() + 5) {
                    let contacts = Contacts.getContacts()
                    web.request(.uploadContacts(contacts: contacts)) { (_) in }
                }
            }
        }
    }
    
    private func runOnboardingFlow() {
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
    
    private func runMainFlow(user: User, token: String, isIMFlowSelected: Bool = false) {
        let (coordinator, flow) = coordinatorFactory.makeMainCoordinator(user: user, token: token)
        addDependency(coordinator)
        router.setRootFlow(flow)
        coordinator.start()
        if isIMFlowSelected {
            flow.selectIMFlow()
        }
        web.request(.startup) { (_) in }
    }
}

private enum LaunchInstructor {
    case main(user: User, token: String)
    case auth
    case onboarding
    
    static func configure(tutorialWasShown: Bool = onboardingWasShown) -> LaunchInstructor {
        if tutorialWasShown == false {
            return .onboarding
        }
        
        guard let IDString = Defaults[.userID], let userID = UInt64(IDString), let token = Defaults[.token] else {
            return .auth
        }
        if let data = Storage(userID: userID).realm.object(ofType: UserData.self, forPrimaryKey: Int64(userID)) {
            let user = User(data: data)
            return .main(user: user, token: token)
        }
        return .auth
    }
}
