//
//  MainController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class MainController: UIPageViewController, MainView {
    var onIMFlowSelect: ((UINavigationController) -> Void)?
    var onViewDidLoad: ((UINavigationController) -> Void)?
    var onStoryFlowSelect: ((UINavigationController) -> Void)?
    var onCardsFlowSelect: ((UINavigationController) -> Void)?
    
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
        
        controllers = [story, cards, imList]
        dataSource = self
        onCardsFlowSelect?(cards)
        setViewControllers([cards], direction: .forward, animated: false, completion: nil)
    }
}

extension MainController: UIPageViewControllerDataSource {
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard
            let nav = viewController as? UINavigationController,
            let pageIndex = controllers.index(of: nav),
            pageIndex > 0
        else { return nil }
        return viewControllerForPage(at: pageIndex - 1)
    }
    
    func pageViewController(
        _ pageViewController: UIPageViewController,
        viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard
            let nav = viewController as? UINavigationController,
            let pageIndex = controllers.index(of: nav),
            pageIndex < controllers.count - 1
            else { return nil }
        return viewControllerForPage(at: pageIndex + 1)
    }
    
    private func viewControllerForPage(at index: Int) -> UIViewController {
        let nav = controllers[index]
        if index == 0 {
            onStoryFlowSelect?(nav)
        } else if index == 1 {
            onCardsFlowSelect?(nav)
        } else if index == 2 {
            onIMFlowSelect?(nav)
        }
        return nav
    }
}
