//
//  OnboardingCoordinator.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol OnboardingCoordinatorOutput: class {
    var finishFlow: (() -> Void)? { get set }
}

final class OnboardingCoordinator: BaseCoordinator, OnboardingCoordinatorOutput {
    var finishFlow: (() -> Void)?
    
    private let factory: OnboardingFlowFactory
    private let router: Router
    
    init(with factory: OnboardingFlowFactory, router: Router) {
        self.factory = factory
        self.router = router
    }
    
    override func start() {
        showOnboarding()
    }
    
    func showOnboarding() {
        let flow = factory.makeOnboardingFlow()
        flow.onFinish = { [weak self] in self?.finishFlow?() }
        router.setRootFlow(flow.toPresent())
    }
}
