//
//  MainController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Pageboy

final class MainController: PageboyViewController, MainView {
    var onIMFlowSelect: ((UINavigationController) -> Void)?
    var onViewDidLoad: ((UINavigationController) -> Void)?
    var onStoryFlowSelect: ((UINavigationController) -> Void)?
    var onCardsFlowSelect: ((UINavigationController) -> Void)?
    var onProfileFlowSelect: ((UINavigationController) -> Void)?
    
    var controllers = [UINavigationController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        logger.debug("")
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        
        if let nav = navigationController { onViewDidLoad?(nav) }
        
        let story = UINavigationController()
        let cards = UINavigationController()
        let imList = UINavigationController()
        let profile = UINavigationController()
        controllers = [story, cards, imList, profile]
        dataSource = self
        onCardsFlowSelect?(cards)
    }
}

extension MainController: PageboyViewControllerDataSource {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return controllers.count
    }
    
    func viewController(
        for pageboyViewController: PageboyViewController,
        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return viewControllerForPage(at: index)
    }
    
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return .at(index: 1)
    }
    
    private func viewControllerForPage(at index: Int) -> UIViewController {
        let nav = controllers[index]
        if index == 0 {
            onStoryFlowSelect?(nav)
        } else if index == 1 {
            onCardsFlowSelect?(nav)
        } else if index == 2 {
            onIMFlowSelect?(nav)
        } else if index == 3 {
            onProfileFlowSelect?(nav)
        }
        return nav
    }
}
