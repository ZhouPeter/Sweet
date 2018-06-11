//
//  CoordinatorFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {
    
    func makeProfileCoordinator(user: User, userID: UInt64, router: Router) -> Coordinator & ProfileCoordinatorOutput {
        return ProfileCoordinator(
                user: user,
                userID: userID,
                router: router,
                factory: FlowFactoryImp(),
                coordinatorFactory: CoordinatorFactoryImp())
    }
    
    func makePowerCoordinator(router: Router) -> Coordinator & PowerCoordinatorOutput {
        return PowerCoordinator(with: FlowFactoryImp(), router: router)
    }
    
    func makeOnboardingCoordinator(router: Router) -> Coordinator & OnboardingCoordinatorOutput {
        return OnboardingCoordinator(with: FlowFactoryImp(), router: router)
    }
    
    func makeAuthCoordinator(router: Router) -> Coordinator & AuthCoordinatorOutput {
        return AuthCoordinator(with: FlowFactoryImp(), router: router)
    }
    
    func makeMainCoordinator(user: User, token: String) -> (coordinator: Coordinator, toPresent: Presentable?) {
        let controller = MainController()
        let coordinator = MainCoordinator(
            user: user,
            token: token,
            mainView: controller,
            coordinatorFactory: CoordinatorFactoryImp()
        )
        return (coordinator, controller)
    }
    
    func makeIMCoordinator(
        user: User,
        token: String,
        navigation: UINavigationController?) -> Coordinator {
        return IMCoordinator(
            user: user,
            token: token,
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
    
    func makeStoryCoordinator(user: User, navigation: UINavigationController?) -> Coordinator {
        return StoryCoordinator(
            user: user,
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
    
    func makeRouter(with navigation: UINavigationController?) -> Router {
        if let nav = navigation {
            return RouterImp(rootController: nav)
        }
        guard let app = UIApplication.shared.delegate as? AppDelegate else { fatalError() }
        return RouterImp(rootController: app.rootController)
    }
    
    func makeContactsCoordinator(router: Router, token: String, storage: Storage, user: User) -> ContactsCoordinator {
        return ContactsCoordinator(
            token: token,
            storage: storage,
            router: router,
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp(),
            user: user
        )
    }
    
    func makeInboxCoordinator(user: User, router: Router, token: String) -> InboxCoordinator {
        return InboxCoordinator(
            user: user,
            token: token,
            router: router,
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp()
        )
    }
}
