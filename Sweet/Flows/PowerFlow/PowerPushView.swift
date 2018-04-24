//
//  PowerPushView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol PowerPushView: BaseView {
    var onFinish: (() -> Void)? { get set }
}
