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
        showIMView()
    }
    
    // MARK: - Private
    
    private func showIMView() {
        let view = factory.makeIMView()
        view.didShowContacts = { [weak self] view in
            view.delegate = self
        }
        view.didShowInbox = { [weak self] view in
            view.showProfile = { self?.showSelfProfile() }
            guard let `self` = self, self.isAvatarLoaded == false else { return }
            var urlString: String?
            self.storage.read({ (realm) in
                guard let user = realm.object(ofType: User.self, forPrimaryKey: self.storage.userID) else { return }
                urlString = user.avatarURLString + "?imageView2/1/w/30/h/30"
            }, callback: {
                guard let urlString = urlString else { return }
                view.didUpdateAvatar(URLString: urlString)
                self.isAvatarLoaded = true
            })
        }
        router.setRootFlow(view)
    }
    
    private func showSelfProfile() {
        let coordinator = self.coordinatorFactory.makeProfileCoordinator(router: router)
        coordinator.finishFlow = { [weak self] in
            self?.removeDependency(coordinator)
        }
        addDependency(coordinator)
        coordinator.start()
    }
}

extension IMCoordinator: ContactsViewDelegate {
    func contactsShowSearch() {
        let searchView = factory.makeContactSearchOutput()
        searchView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(searchView)
    }
    
    func contactsShowSubscription() {
        let subscriptionView = factory.makeSubscriptionOutput()
        subscriptionView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(subscriptionView)
    }
    
    func contactsShowInvite() {
        let inviteView = factory.makeInviteOutput()
        router.push(inviteView)
    }
    
    func contactsShowBlock() {
        let blockView = factory.makeBlockOutput()
        blockView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(blockView)
    }
    
    func contactsShowProfile(userID: UInt64) {
        showProfile(userID: userID)
    }
    
    func contactsShowBlack() {
        let blackView = factory.makeBlackOutput()
        blackView.showProfile = { [weak self] userId in
            self?.showProfile(userID: userId)
        }
        router.push(blackView)
    }
    
    private func showProfile(userID: UInt64) {
        let profileView = factory.makeProfileOutput(userId: userID)
        router.push(profileView)
    }
}
