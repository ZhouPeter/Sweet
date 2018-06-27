//
//  MainController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Pageboy
import VolumeBar

extension UINavigationController {
    open override var childViewControllerForStatusBarStyle: UIViewController? {
        return self.topViewController
    }

    open override var childViewControllerForStatusBarHidden: UIViewController? {
        return self.topViewController
    }
}

extension Notification.Name {
    static let DisablePageScroll = Notification.Name(rawValue: "DisablePageScroll")
    static let EnablePageScroll = Notification.Name(rawValue: "EnablePageScroll")
    static let BlackBarStyle = Notification.Name(rawValue: "BlackBarStyle")
    static let DefaultBarStyle = Notification.Name(rawValue: "DefaultBarStyle")
    static let ScrollPage = Notification.Name(rawValue: "ScrollPage")
    static let BlackStatusBar = Notification.Name(rawValue: "BlackStatusBar")
    static let WhiteStatusBar = Notification.Name(rawValue: "WhiteStatusBar")
    static let ScrollToPage = Notification.Name(rawValue: "ScrollToPage")
    static let StatusBarHidden = Notification.Name(rawValue: "StatusBarHidden")
    static let StatusBarNoHidden = Notification.Name(rawValue: "StatusBarNoHidden")
}

final class MainController: PageboyViewController, MainView {
    var userID: UInt64 = 0
    var token: String = ""
    var onIMFlowSelect: ((UINavigationController) -> Void)?
    var onViewDidLoad: ((UINavigationController) -> Void)?
    var onStoryFlowSelect: ((UINavigationController) -> Void)?
    var onCardsFlowSelect: ((UINavigationController) -> Void)?
    private var controllers = [UINavigationController]()
    private var statusBarStyle = UIStatusBarStyle.lightContent
    private var statusBarHidden: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        navigationController?.navigationBar.isHidden = true
        if let nav = navigationController { onViewDidLoad?(nav) }
        let story = UINavigationController()
        let cards = UINavigationController()
        let imList = UINavigationController()
        controllers = [story, cards, imList]
        dataSource = self
        delegate = self
        bounces = false
        onCardsFlowSelect?(cards)
        edgesForExtendedLayout = []

        addObservers()
        onStoryFlowSelect?(story)
        onIMFlowSelect?(imList)
        
        VolumeBar.shared.start()
        UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelAlert
        DispatchQueue.main.async {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return statusBarStyle
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        return .fade
    }
    
    override var prefersStatusBarHidden: Bool {
        return statusBarHidden
    }
    
    // MARK: - Private
    
    private func addObservers() {
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
            name: .BlackBarStyle,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBarStyleDefaultNote),
            name: .DefaultBarStyle,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveScrollPage(_:)),
            name: .ScrollPage,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveBlackStatusBarNote),
            name: .BlackStatusBar,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveWhiteStatusBarNote),
            name: .WhiteStatusBar,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStatusBarHidden),
            name: .StatusBarHidden,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didReceiveStatusBarNoHidden),
            name: .StatusBarNoHidden,
            object: nil
        )
    }
    
    @objc func didReceivePageScrollDiableNote() {
        isScrollEnabled = false
    }

    @objc func didReceivePageScrollEnableNote() {
        isScrollEnabled = true
    }
    
    @objc func didReceiveBarStyleBlackNote() {
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.tintColor = .white
    }
    
    @objc func didReceiveBarStyleDefaultNote() {
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        
    }

    @objc func didReceiveScrollPage(_ note: Notification) {
        guard let index = note.object as? Int else { return }
        scrollToPage(.at(index: index), animated: true)
    }
    
    @objc func didReceiveBlackStatusBarNote() {
        guard statusBarStyle != .default else { return }
        statusBarStyle = .default
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func didReceiveWhiteStatusBarNote() {
        guard statusBarStyle != .lightContent else { return }
        statusBarStyle = .lightContent
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func didReceiveStatusBarHidden() {
        guard statusBarHidden != true else { return }
        statusBarHidden = true
        setNeedsStatusBarAppearanceUpdate()
    }
    
    @objc func didReceiveStatusBarNoHidden() {
        guard statusBarHidden != false else { return }
        statusBarHidden = false
        setNeedsStatusBarAppearanceUpdate()
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
    
    func pageboyViewController(
        _ pageboyViewController: PageboyViewController,
        willScrollToPageAt index: Int,
        direction: PageboyViewController.NavigationDirection,
        animated: Bool) {
        NotificationCenter.default.post(name: Notification.Name.ScrollToPage, object: ["index": index])
    }
    
    private func updateStatusBar(at index: Int) {
        if index == 0 {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelStatusBar
        } else {
            UIApplication.shared.keyWindow?.windowLevel = UIWindowLevelNormal
        }
    }
}
