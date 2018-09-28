//
//  IMCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
import Realm
final class IMCoordinator: BaseCoordinator {
    private let factory: IMFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    private let user: User
    private let token: String
    private let storage: Storage
    private var isAvatarLoaded = false
    private lazy var imView: IMView = self.factory.makeIMView()
    private var contactsCoordinator: ContactsCoordinator?
    private var inboxCoordinator: InboxCoordinator?
    
    init(user: User,
         token: String,
         router: Router,
         factory: IMFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.user = user
        self.token = token
        self.storage = Storage(userID: user.userId)
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        imView.delegate = self
        _ = imView.toPresent()?.view
        router.setRootFlow(imView)
    }
    
    private func updateAvatar() {
        var urlString: String?
        self.storage.read({ [weak self] (realm) in
            guard let user = realm.object(ofType: UserData.self, forPrimaryKey: self?.storage.userID) else { return }
            urlString = user.avatarURLString + "?imageView2/1/w/30/h/30"
        }, callback: { [weak self] in
            guard let urlString = urlString else { return }
            self?.imView.updateAvatarImage(withURLString: urlString)
        })
    }
}

extension IMCoordinator: IMViewDelegate {
    func imViewDidLoad() {
        updateAvatar()
    }
    
    func imViewDidPressAvatarButton() {
        let coordinator = self.coordinatorFactory.makeProfileCoordinator(user: user,
                                                                         buddyID: user.userId,
                                                                         router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    func imViewDidShowInbox(_ view: InboxView) {
        guard inboxCoordinator == nil else {
            inboxCoordinator?.start()
            updateAvatar()
            return
        }
        let coordinator = coordinatorFactory.makeInboxCoordinator(user: user, router: router, token: token)
        coordinator.start(with: view)
        inboxCoordinator = coordinator
    }
    
    func imViewDidShowContacts(_ view: ContactsView) {
        guard contactsCoordinator == nil else { return }
        let coordinator = coordinatorFactory
            .makeContactsCoordinator(router: router, token: token, storage: storage, user: user)
        coordinator.start(with: view)
        contactsCoordinator = coordinator
    }
    
    private func showProfile(userID: UInt64) {
        let coordinator = self.coordinatorFactory.makeProfileCoordinator(user: user,
                                                                         buddyID: userID,
                                                                         router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}
