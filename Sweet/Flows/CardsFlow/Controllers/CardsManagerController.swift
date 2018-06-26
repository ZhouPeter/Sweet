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
    var delegate: CardsManagerViewDelegate? { get set }
}

protocol CardsManagerViewDelegate: class {
    func showAll(view: CardsAllView)
    func showSubscription(view: CardsSubscriptionView)
}

class CardsManagerController: BaseViewController, CardsManagerView {

    weak var delegate: CardsManagerViewDelegate?
    var user: User
    private var allView: CardsAllController
    private var subscriptionView: CardsSubscriptionController
    
    init(user: User) {
        self.user = user
        self.allView = CardsAllController(user: user)
        self.subscriptionView = CardsSubscriptionController(user: user)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private lazy var titleView: CustomSegmentedControl = {
        let control = CustomSegmentedControl(items: ["全部", "订阅"])
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(switchView(_:)), for: .valueChanged)
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
    private var isAllShown = true
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: leftButton)
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)
        setupControllers()
        automaticallyAdjustsScrollViewInsets = false
        Messenger.shared.addDelegate(self)
        showAll(true)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollToPage(_:)),
                                               name: Notification.Name.ScrollToPage,
                                               object: nil)
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .WhiteStatusBar, object: nil)
        navigationController?.navigationBar.barTintColor = UIColor.xpNavBlue()
        navigationController?.navigationBar.barStyle = .black
       
        if Defaults[.isPersonalStoryChecked] {
            leftBadgeView.isHidden = true
        } else {
            leftBadgeView.isHidden = false
            leftBadgeView.text = nil
        }
    }
    
    // MARK: - Private
    private func setupControllers() {
        add(childViewController: subscriptionView)
        subscriptionView.view.fill(in: view)
        add(childViewController: allView)
        allView.view.fill(in: view)
    }
    private func showAll(_ isAllShown: Bool) {
        self.isAllShown = isAllShown
        allView.view.alpha = isAllShown ? 1 : 0
        if isAllShown {
            delegate?.showAll(view: allView)
            allView.loadCards()
        } else {
            delegate?.showSubscription(view: subscriptionView)
            subscriptionView.loadCards()
        }
    }
    
    @objc private func switchView(_ sender: CustomSegmentedControl) {
        showAll(sender.selectedSegmentIndex == 0)
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
        if showScrollNavGuide() { return }
        NotificationCenter.default.post(name: Notification.Name.ScrollPage, object: 0)
    }
    
    @objc private func rightAction(sender: UIButton) {
        if showScrollNavGuide() { return }
        NotificationCenter.default.post(name: Notification.Name.ScrollPage, object: 2)
    }
    
    private func showScrollNavGuide() -> Bool {
        if Defaults[.isScrollNavigationGuideShown] == false {
            Guide.showSwipeTip("划动屏幕也能切换页面")
            Defaults[.isScrollNavigationGuideShown] = true
            return true
        }
         return false
    }
    
    @objc private func scrollToPage(_ noti: Notification) {
        if let object = noti.object as? [String: Any], let index = object["index"] as? Int {
            if  index == 1 {
                titleView.selectedSegmentIndex = 0
                showAll(true)
            }
        }
    }
}
