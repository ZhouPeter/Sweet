//
//  ActionSetController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Pageboy
protocol PageChildrenProtocol {
    var user: User { get set }
    var cellNumber: Int { get set }
    func loadRequest()
}

protocol ActionsControllerDelegate: NSObjectProtocol {
    func actionsScrollViewDidScroll(scrollView: UIScrollView)
    func actionsSrollViewDidScrollToBottom(scrollView: UIScrollView, index: Int)
}
class ActionsController: PageboyViewController {
    var showStoriesPlayerView: (
    (
     User,
     [StoryCellViewModel],
     Int,
     StoriesPlayerGroupViewControllerDelegate?) -> Void
    )?
    var user: User {
        didSet {
            for index in 0..<pageControllers.count {
                pageControllers[index].user = user
            }
        }
    }
    var showStory: (() -> Void)?
    var showProfile: ((UInt64, SetTop?, (() -> Void)?) -> Void)?
    var mine: User
    let setTop: SetTop?
    weak var actionsDelegate: ActionsControllerDelegate?
    init(user: User, mine: User, setTop: SetTop? = nil) {
        self.user = user
        self.mine = mine
        self.setTop = setTop
        super.init(nibName: nil, bundle: nil)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    lazy var pageControllers: [UIViewController & PageChildrenProtocol] = {
        var viewControllers = [UIViewController & PageChildrenProtocol]()
        let feedsController = ActivitiesController(user: user, avatar: mine.avatar, setTop: setTop)
        feedsController.showProfile = showProfile
        feedsController.delegate = self
        let storysController = StoriesController(user: user)
        storysController.delegate = self
        storysController.showStory = showStory
        storysController.showStoriesPlayerView = showStoriesPlayerView
        viewControllers.append(feedsController)
        viewControllers.append(storysController)
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isScrollEnabled = false
        dataSource = self
        delegate = self
//        pageControllers[0].loadRequest()
    }

}
extension ActionsController: ActivitiesControllerDelegate, StoriesControllerDelegate {
    func storiesScrollViewDidScrollToBottom(scrollView: UIScrollView, index: Int) {
        actionsDelegate?.actionsSrollViewDidScrollToBottom(scrollView: scrollView, index: index)
    }
    
    func acitvitiesScrollViewDidScroll(scrollView: UIScrollView) {
        actionsDelegate?.actionsScrollViewDidScroll(scrollView: scrollView)
    }
    func storiesScrollViewDidScroll(scrollView: UIScrollView) {
        actionsDelegate?.actionsScrollViewDidScroll(scrollView: scrollView)
    }

}

extension ActionsController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
        
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 0)
    }
}

extension ActionsController: PageboyViewControllerDelegate {
    func pageboyViewController(_ pageboyViewController: PageboyViewController,
                               willScrollToPageAt index: Int,
                               direction: PageboyViewController.NavigationDirection, animated: Bool) {
        let viewController = pageControllers[index]
        viewController.loadRequest()
    }
    
}
