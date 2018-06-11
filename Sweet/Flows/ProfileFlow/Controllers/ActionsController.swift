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
    var userId: UInt64 { get set }
    func loadRequest()
}
class ActionsController: PageboyViewController {
    var userId: UInt64 {
        didSet {
            for index in 0..<pageControllers.count {
                pageControllers[index].userId = userId
            }
        }
    }
    init(userId: UInt64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var pageControllers: [UIViewController & PageChildrenProtocol] = {
        var viewControllers = [UIViewController & PageChildrenProtocol]()
        let feedsController = ActivitiesController(userId: userId)
        let storysController = StoriesController(userId: userId)
        let estimatesController = EvaluationController(userId: userId)
        viewControllers.append(feedsController)
        viewControllers.append(storysController)
        viewControllers.append(estimatesController)
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        isScrollEnabled = false
        dataSource = self
        delegate = self
        pageControllers[0].loadRequest()
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
