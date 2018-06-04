//
//  IMFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol IMFlowFactory {
    func makeIMView() -> IMView
    func makeContactSearchOutput() -> ContactSearchView
}
