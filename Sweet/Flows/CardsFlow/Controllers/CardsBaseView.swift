//
//  CardsBaseView.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/13.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol CardsBaseView: BaseView {
    var delegate: CardsBaseViewDelegate? { get set }
}

protocol CardsBaseViewDelegate: class {
    func showProfile(userId: UInt64)
    func showStoriesGroup(user: User,
                          storiesGroup: [[StoryCellViewModel]],
                          currentIndex: Int,
                          fromCardId: String?,
                          delegate: StoriesPlayerGroupViewControllerDelegate,
                          completion: (() -> Void)?)
}
