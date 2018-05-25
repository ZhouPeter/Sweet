//
//  MainController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Pageboy

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.visibleViewController
    }
}

extension Notification.Name {
    static let DisablePageScroll = Notification.Name(rawValue: "DisablePageScroll")
    static let EnablePageScroll = Notification.Name(rawValue: "EnablePageScroll")
    static let BarStyleBlack = Notification.Name(rawValue: "BarStyleBlack")
    static let BarStyleDefault = Notification.Name(rawValue: "BarStyleDefalut")
    static let ScrollPage = Notification.Name(rawValue: "ScrollPage")
}

final class MainController: PageboyViewController, MainView {
    var preloadStory: ((UINavigationController) -> Void)?
    var onIMFlowSelect: ((UINavigationController) -> Void)?
    var onViewDidLoad: ((UINavigationController) -> Void)?
    var onStoryFlowSelect: ((UINavigationController) -> Void)?
    var onCardsFlowSelect: ((UINavigationController) -> Void)?
    var onProfileFlowSelect: ((UINavigationController) -> Void)?
    
    private var controllers = [UINavigationController]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        if let nav = navigationController { onViewDidLoad?(nav) }
        let story = UINavigationController()
        let cards = UINavigationController()
        let imList = UINavigationController()
        let profile = UINavigationController()
        controllers = [story, cards, imList, profile]
        dataSource = self
        delegate = self
        onCardsFlowSelect?(cards)
        edgesForExtendedLayout = []

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePageScrollDiableNote),
            name: .DisablePageScroll,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceivePageScrollEnableNote),
            name: .EnablePageScroll,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBarStyleBlackNote),
            name: .BarStyleBlack,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBarStyleDefaultNote),
            name: .BarStyleDefault,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveScrollPage(_:)),
            name: .ScrollPage,
            object: nil
        )
        preloadStory?(story)
    }
    
    // MARK: - Private
    
    @objc func didReceivePageScrollDiableNote() {
        isScrollEnabled = false
    }

    @objc func didReceivePageScrollEnableNote() {
        isScrollEnabled = true
    }
    
    @objc func didReceiveBarStyleBlackNote() {
        navigationController?.navigationBar.barStyle = .black
    }
    
    @objc func didReceiveBarStyleDefaultNote() {
        navigationController?.navigationBar.barStyle = .default
    }

    @objc func didReceiveScrollPage(_ note: Notification) {
        guard let index = note.object as? Int else { return }
        scrollToPage(.at(index: index), animated: true)
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

extension MainController: PageboyViewControllerDelegate {
    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        didScrollToPageAt index: Int,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool) {
        updateStatusBar(at: index)
    }
    
    private func updateStatusBar(at index: Int) {
        if index == 0 {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar
        } else {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        }
    }
}
