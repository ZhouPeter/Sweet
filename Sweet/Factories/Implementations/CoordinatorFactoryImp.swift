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
    
    func makeMainCoordinator() -> (coordinator: Coordinator, toPresent: Presentable?) {
        let controller = MainController()
        let coordinator = MainCoordinator(mainView: controller, coordinatorFactory: CoordinatorFactoryImp())
        return (coordinator, controller)
    }
    
    func makeIMCoordinator(navigation: UINavigationController?) -> Coordinator {
        return IMCoordinator(
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
    
    func makeCardsCoordinator(navigation: UINavigationController?) -> Coordinator {
        return CardsCoordinator(
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
    
    func makeStoryCoordinator(navigation: UINavigationController?) -> Coordinator {
        return StoryCoordinator(
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
    func makeProfileCoordinator(navigation: UINavigationController?) -> Coordinator {
        return ProfileCoordinator(
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp())
    }
    
    func makeRouter(with navigation: UINavigationController?) -> Router {
        if let nav = navigation {
            return RouterImp(rootController: nav)
        }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return RouterImp(rootController: app.rootController)
    }
}
