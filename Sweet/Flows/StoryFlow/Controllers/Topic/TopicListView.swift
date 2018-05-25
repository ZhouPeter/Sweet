//
//  TopicListView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/25.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol TopicListView: BaseView {
    var onFinished: ((String?) -> Void)? { get set }
    var onCancelled: (() -> Void)? { get set }
}
