//
//  PowerContactsView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation
protocol PowerContactsView: BaseView {
    var showPush: (() -> Void)? { get set }
    var onFinish: (() -> Void)? { get set }
}
