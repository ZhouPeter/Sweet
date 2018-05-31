//
//  ProfileCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol ProfileCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

class ProfileCoordinator: BaseCoordinator, ProfileCoordinatorOutput {
    var finishFlow: (() -> Void)?
    private let factory: ProfileFlowFactory
    private let coordinatorFactory: CoordinatorFactory
    private let router: Router
    
    init(router: Router, factory: ProfileFlowFactory, coordinatorFactory: CoordinatorFactory) {
        self.router = router
        self.factory = factory
        self.coordinatorFactory = coordinatorFactory
    }
    
    override func start() {
        showProfile()
    }
    
    // MARK: - Private
    private func showProfile() {
        let profileModule = factory.makeProfileModule()
        profileModule.showAbout = { [weak self] (user) in
            self?.showAbout(user: user)
        }
        profileModule.finished = { [weak self] in
            self?.finishFlow?()
        }
        router.push(profileModule)
    }
    
    private func showAbout(user: UserResponse) {
        let aboutOutput  = factory.makeProfileAboutOutput(user: user)
        aboutOutput.showWebView = { [weak self] (title, urlString) in
            self?.showWebView(title: title, urlString: urlString)
        }
        
        aboutOutput.showFeedback = {
            
        }
        
        aboutOutput.showUpdate = { [weak self] (user) in
            self?.showUpdate(user: user)
        }
        router.push(aboutOutput)
    }
    
    private func showUpdate(user: UserResponse) {
        let updateOutput = factory.makeProfileUpdateOutput(user: user)
        router.push(updateOutput)
    }
    
    private func showWebView(title: String, urlString: String) {
        let webViewController = WebViewController(urlString: urlString)
        webViewController.navigationItem.title = title
        router.push(webViewController)
    }
}
