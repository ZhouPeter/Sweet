//
//  StoryEditView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryEditView: BaseView {
    var onCancelled: (() -> Void)? { get set }
    var onFinished: ((URL) -> Void)? { get set }
}
