//
//  StoryPlayerFlowFactory.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/21.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol StoryPlayerFlowFactory {
    func makeStoriesPlayerView(user: User,
                               stories: [StoryCellViewModel],
                               current: Int,
                               delegate: StoriesPlayerViewControllerDelegate?) -> StoriesPlayerView
    func makeStoiesGroupView(user: User,
                             storiesGroup: [[StoryCellViewModel]],
                             currentIndex: Int,
                             currentStart: Int,
                             fromCardId: String?,
                             delegate: StoriesPlayerGroupViewControllerDelegate?) -> StoriesGroupView
    
}
