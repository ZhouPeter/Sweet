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
    func showProfile(buddyID: UInt64, setTop: SetTop?)
    func showStoriesGroup(storiesGroup: [[StoryCellViewModel]],
                          currentIndex: Int,
                          fromCardId: String?,
                          delegate: StoriesPlayerGroupViewControllerDelegate?,
                          completion: (() -> Void)?)
    func showLikeRankList(title: String)
    func showGroupConversation(groupId: UInt64)
}
