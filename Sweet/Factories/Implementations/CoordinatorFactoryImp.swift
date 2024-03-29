//
//  CoordinatorFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class CoordinatorFactoryImp: CoordinatorFactory {
    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        storiesGroup: [[StoryCellViewModel]],
        isCanOpenEdit: Bool,
        delegate: StoriesPlayerGroupViewControllerDelegate?) -> Coordinator & StoryPlayerCoordinatorOutput {
        return StoryPlayerCoordinator(user: user, router: makeRouter(with: navigation), factory: FlowFactoryImp(),
                                      coordinatorFactory: CoordinatorFactoryImp(), storiesGroup: storiesGroup,
                                      delegate: delegate, isCanOpenEdit: isCanOpenEdit)
    }
    
    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        fromMessageId: String?,
        storiesGroup: [[StoryCellViewModel]]) -> Coordinator & StoryPlayerCoordinatorOutput {
        return StoryPlayerCoordinator(user: user, router: makeRouter(with: navigation), factory: FlowFactoryImp(),
                                      coordinatorFactory: CoordinatorFactoryImp(),
                                      storiesGroup: storiesGroup, fromMessageId: fromMessageId)
    }
    
    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        currentStart: Int,
        fromUserId: UInt64?,
        storiesGroup: [[StoryCellViewModel]],
        delegate: StoriesPlayerGroupViewControllerDelegate?) -> Coordinator & StoryPlayerCoordinatorOutput {
        return StoryPlayerCoordinator(user: user, router: makeRouter(with: navigation), factory: FlowFactoryImp(),
                                      coordinatorFactory: CoordinatorFactoryImp(), storiesGroup: storiesGroup,
                                      current: 0, currentStart: currentStart, delegate: delegate,
                                      fromCardId: nil, fromUserId: fromUserId)
    }

    func makeStoryPlayerCoordinator(
        user: User,
        navigation: UINavigationController?,
        current: Int,
        currentStart: Int,
        fromCardId: String?,
        storiesGroup: [[StoryCellViewModel]],
        delegate: StoriesPlayerGroupViewControllerDelegate?) -> Coordinator & StoryPlayerCoordinatorOutput {
        return StoryPlayerCoordinator(user: user, router: makeRouter(with: navigation), factory: FlowFactoryImp(),
                                      coordinatorFactory: CoordinatorFactoryImp(), storiesGroup: storiesGroup,
                                      current: current, currentStart: currentStart,
                                      delegate: delegate, fromCardId: fromCardId)
    }
    
    func makeProfileCoordinator(user: User, buddyID: UInt64,
                                setTop: SetTop?, router: Router) -> Coordinator & ProfileCoordinatorOutput {
        return ProfileCoordinator(
                user: user,
                userID: buddyID,
                setTop: setTop,
                router: router,
                factory: FlowFactoryImp(),
                coordinatorFactory: CoordinatorFactoryImp())
    }
    
    func makeProfileCoordinator(user: User, buddyID: UInt64, router: Router) -> Coordinator & ProfileCoordinatorOutput {
        return ProfileCoordinator(
            user: user,
            userID: buddyID,
            router: router,
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp())
    }
    
    func makeProfileCoordinator(user: User,
                                buddyID: UInt64,
                                setTop: SetTop?,
                                navigation: UINavigationController?) -> Coordinator & ProfileCoordinatorOutput {
        return ProfileCoordinator(
                user: user,
                userID: buddyID,
                router: makeRouter(with: navigation),
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
    
    func makeMainCoordinator(user: User, token: String) -> (coordinator: Coordinator, toPresent: MainView) {
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
    
    func makeCardsCoordinator(user: User, navigation: UINavigationController?) -> Coordinator {
        return CardsCoordinator(
            user: user,
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
    
    func makeDismissableStoryCoordinator(user: User, topic: String?, navigation: UINavigationController?) -> Coordinator & StoryCoodinatorOutput {
        return StoryCoordinator(
            user: user,
            router: makeRouter(with: navigation),
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp(),
            isDismissable: true,
            topic: topic
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
    
    func makeAllCardsCoordinator(user: User, router: Router) -> AllCardsCoordinator {
        return AllCardsCoordinator(
            user: user,
            router: router,
            factory: FlowFactoryImp(),
            coordinatorFactory: CoordinatorFactoryImp())
    }
    
}
