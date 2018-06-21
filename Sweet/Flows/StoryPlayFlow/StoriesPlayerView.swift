//
//  StoriesPlayerView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/21.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoriesPlayerView: BaseView {
    var runStoryFlow: ((_ topic: String) -> Void)? { get set }
    var runProfileFlow: ((_ user: User, _ buddyID: UInt64) -> Void)? { get set }
    var onFinish: (() -> Void)? { get set }
    func reloadPlayer()
    func pause()
    func play()
}
