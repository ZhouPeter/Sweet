//
//  StoryTextView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryTextView: BaseView {
    var onFinished: (() -> Void)? { get set }
    var onCancelled: (() -> Void)? { get set}
}
