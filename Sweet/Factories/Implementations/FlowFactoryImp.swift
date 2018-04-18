//
//  FlowFactoryImp.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/18.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

final class FlowFactoryImp: OnboardingFlowFactory {
    func makeOnboardingFlow() -> OnboardingView {
        return OnboardingController()
    }
}
