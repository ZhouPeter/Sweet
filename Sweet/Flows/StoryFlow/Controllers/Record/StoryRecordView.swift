//
//  StoryRecordView.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryRecordView: BaseView {
    var onRecorded: ((_ fileURL: URL, _ isPhoto: Bool, _ topic: String?) -> Void)? { get set }
    var onTextChoosed: (() -> Void)? { get set }
}
