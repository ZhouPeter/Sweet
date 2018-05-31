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
    private let token: String
    private let storage: Storage
    private var isAvatarLoaded = false
    private lazy var imView: IMView = self.factory.makeIMView()
    private var contactsCoordinator: ContactsCoordinator?
    private var inboxCoordinator: InboxCoordinator?
    
    init(token: String,
         storage: Storage,
         router: Router,
         factory: IMFlowFactory,
         coordinatorFactory: CoordinatorFactory) {
        self.token = token
        self.storage = storage
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        imView.delegate = self
        _ = imView.toPresent()?.view
        router.setRootFlow(imView)
    }
}

extension IMCoordinator: IMViewDelegate {
    func imViewDidLoad() {
        var urlString: String?
        self.storage.read({ (realm) in
            guard let user = realm.object(ofType: User.self, forPrimaryKey: self.storage.userID) else { return }
            urlString = user.avatarURLString + "?imageView2/1/w/30/h/30"
        }, callback: { [weak self] in
            guard let urlString = urlString else { return }
            self?.imView.updateAvatarImage(withURLString: urlString)
        })
    }
    
    func imViewDidPressSearchButton() {
        let searchView = factory.makeContactSearchOutput()
        searchView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(searchView)
    }
    
    func imViewDidPressAvatarButton() {
        let coordinator = self.coordinatorFactory.makeProfileCoordinator(router: router)
        coordinator.finishFlow = { [weak self, weak coordinator] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
    
    func imViewDidShowInbox(_ view: InboxView) {
        guard inboxCoordinator == nil else {
            inboxCoordinator?.start()
            return
        }
        let coordinator = coordinatorFactory
            .makeInboxCoordinator(router: router, token: token, storage: storage)
        coordinator.start(with: view)
        inboxCoordinator = coordinator
    }
    
    func imViewDidShowContacts(_ view: ContactsView) {
        guard contactsCoordinator == nil else { return }
        let coordinator = coordinatorFactory
            .makeContactsCoordinator(router: router, token: token, storage: storage)
        coordinator.start(with: view)
        contactsCoordinator = coordinator
    }
    
    private func showProfile(userID: UInt64) {
        let profileView = factory.makeProfileOutput(userId: userID)
        router.push(profileView)
    }
}
