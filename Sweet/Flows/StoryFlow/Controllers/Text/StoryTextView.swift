//
//  StoryTextView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/3.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryTextView {
    var onFinished: ((StoryText) -> Void)? { get set }
}

struct StoryText {
    let color: UIColor
    let text: String
    let tag: String
}
