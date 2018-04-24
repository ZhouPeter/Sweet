//
//  PowerCoordinator.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol PowerCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

class PowerCoordinator: BaseCoordinator, PowerCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private let factory: PowerFlowFactory
    private let router: Router
    
    init(with factory: PowerFlowFactory, router: Router) {
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showContacts()
    }
    
    func showContacts() {
        let contactsOutput = factory.makePowerContactsOutput()
        contactsOutput.showPush = { [weak self] in
            self?.showPush()
        }
        router.setRootFlow(contactsOutput.toPresent())
    }
    
    private func showPush() {
       let pushOutput = factory.makePowerPushOutput()
        pushOutput.onFinish = { [weak self] in
            self?.finishFlow?()
        }
        router.push(pushOutput)
    }
}
