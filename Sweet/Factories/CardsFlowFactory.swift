//
//  CardsFlowFactory.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/24.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol CardsFlowFactory {
    func makeCardsManagerView(user: User) -> CardsManagerView
    func makeStoiesGroupView(user: User,
                             storiesGroup: [[StoryCellViewModel]],
                             currentIndex: Int,
                             fromCardId: String?,
                             delegate: StoriesPlayerGroupViewControllerDelegate) -> StoriesGroupView
}
