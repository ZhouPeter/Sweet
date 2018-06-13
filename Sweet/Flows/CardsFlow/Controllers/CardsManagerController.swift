//
//  CardsManagerController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol CardsManagerView: BaseView {
    var showAll: ((CardsAllView) -> Void)? { get set }
    var showSubscription: ((CardsSubscriptionView) -> Void)? { get set }
    
}
class CardsManagerController: BaseViewController, CardsManagerView {
    var showAll: ((CardsAllView) -> Void)?
    var showSubscription: ((CardsSubscriptionView) -> Void)?
    var user: User
    var allController: CardsAllController
    var subscriptionController: CardsSubscriptionController
    private var currentController = UIViewController()
    
    init(user: User) {
        self.user = user
        self.allController = CardsAllController(user: user)
        self.subscriptionController = CardsSubscriptionController(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var titleView: UISegmentedControl = {
        let control = UISegmentedControl(items: ["全部", "订阅"])
        control.tintColor = .clear
        let normalTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                    NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        control.setTitleTextAttributes(normalTextAttributes, for: .normal)
        let selectedTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                      NSAttributedStringKey.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(changeController(_:)), for: .valueChanged)
        return control
    }()
    private lazy var leftBadgeView: BadgeView = {
        let view = BadgeView(cornerRadius: 15)
        view.isHidden = true
        view.dotCenterX?.constant = 12
        view.dotCenterY?.constant = -12
        view.clipsToBounds = false
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var rightBadgeView: BadgeView = {
        let view = BadgeView(cornerRadius: 15)
        view.isHidden = true
        view.dotCenterX?.constant = 12
        view.dotCenterY?.constant = -12
        view.isUserInteractionEnabled = false
        return view
    }()
    private lazy var leftButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Camera"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(leftAction(sender:)), for: .touchUpInside)
        button.addSubview(leftBadgeView)
        leftBadgeView.align(.left)
        leftBadgeView.centerY(to: button)
        return button
    }()
    
    private lazy var rightButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Message"), for: .normal)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: #selector(rightAction(sender:)), for: .touchUpInside)
        button.addSubview(rightBadgeView)
        rightBadgeView.align(.left)
        rightBadgeView.centerY(to: button)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.xpNavBlue()
        navigationController?.navigationBar.barStyle = .black
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        addChildViewController(allController)
        allController.didMove(toParentViewController: self)
        view.addSubview(allController.view)
        currentController = allController
        showAll?(allController)
        automaticallyAdjustsScrollViewInsets = false
        Messenger.shared.addDelegate(self)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if Defaults[.isPersonalStoryChecked] {
            leftBadgeView.isHidden = true
        } else {
            leftBadgeView.isHidden = false
            leftBadgeView.text = nil
        }

    }
    
    @objc private func changeController(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0 {
            self.replaceController(oldController: currentController, newController: allController)
        } else {
            self.replaceController(oldController: currentController, newController: subscriptionController)
        }
    }
    
    private func replaceController(oldController: UIViewController, newController: UIViewController) {
        if oldController == newController { return }
        addChildViewController(newController)
        newController.didMove(toParentViewController: self)
        view.addSubview(newController.view)
        oldController.willMove(toParentViewController: nil)
        oldController.removeFromParentViewController()
        oldController.view.removeFromSuperview()
        self.currentController = newController
        if newController is CardsAllController {
            showAll?(allController)
        } else {
            showSubscription?(subscriptionController)
        }
    }

}
extension CardsManagerController: MessengerDelegate {
    func messengerDidUpdateUnreadCount(messageUnread: Int, likesUnread: Int) {
        rightBadgeView.isHidden = false
        rightBadgeView.clipsToBounds = true
        if messageUnread > 0 {
            rightBadgeView.text =  messageUnread > 99 ? "99+" : "\(messageUnread)"
            rightButton.setImage(nil, for: .normal)
        } else if likesUnread > 0 {
            rightBadgeView.text = nil
            rightBadgeView.clipsToBounds = false
            rightButton.setImage(#imageLiteral(resourceName: "Message"), for: .normal)
        } else {
            rightBadgeView.isHidden = true
            rightButton.setImage(#imageLiteral(resourceName: "Message"), for: .normal)
        }
    }
}

// MARK: - Actions
extension CardsManagerController {
    @objc private func leftAction(sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.ScrollPage, object: 0)
    }
    
    @objc private func rightAction(sender: UIButton) {
        NotificationCenter.default.post(name: Notification.Name.ScrollPage, object: 2)
    }
}
