//
//  IMManagerController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class IMController: BaseViewController, IMView {
    weak var delegate: IMViewDelegate?
    private let inboxView = InboxController()
    private let contactsView = ContactsController()
    
    private var isInboxShown = true
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(didPressRightBarButton))
        imageView.addGestureRecognizer(tap)
        return imageView
    } ()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "SearchWhite"), for: .normal)
        button.addTarget(self, action: #selector(didPressRightBarButton), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    } ()
    
    private lazy var titleView: UISegmentedControl = {
        let control = UISegmentedControl(items: ["消息", "联系人"])
        control.tintColor = .clear
        let normalTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                    NSAttributedStringKey.foregroundColor: UIColor.white.withAlphaComponent(0.5)]
        control.setTitleTextAttributes(normalTextAttributes, for: .normal)
        let selectedTextAttributes = [NSAttributedStringKey.font: UIFont.boldSystemFont(ofSize: 18),
                                      NSAttributedStringKey.foregroundColor: UIColor.white]
        control.setTitleTextAttributes(selectedTextAttributes, for: .selected)
        control.selectedSegmentIndex = 0
        control.addTarget(self, action: #selector(switchView(_:)), for: .valueChanged)
        return control
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.titleView = titleView
        automaticallyAdjustsScrollViewInsets = false
        setupControllers()
        delegate?.imViewDidLoad()
        showInbox(true)

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.xpNavBlue()
        navigationController?.navigationBar.barStyle = .black
        NotificationCenter.default.post(name: .WhiteStatusBar, object: nil)
        if isInboxShown {
            delegate?.imViewDidShowInbox(inboxView)
        } else {
            delegate?.imViewDidShowContacts(contactsView)
        }
    }
    
    func updateAvatarImage(withURLString urlString: String) {
        avatarImageView.kf.setImage(with: URL(string: urlString))
    }
    
    // MARK: - Private
    
    private func setupControllers() {
        add(childViewController: contactsView)
        contactsView.view.fill(in: view)
        add(childViewController: inboxView)
        inboxView.view.fill(in: view)
    }
    
    @objc private func switchView(_ control: UISegmentedControl) {
        showInbox(control.selectedSegmentIndex == 0)
    }
    
    @objc private func didPressRightBarButton() {
        if isInboxShown {
            delegate?.imViewDidPressAvatarButton()
        } else {
            delegate?.imViewDidPressSearchButton()
        }
    }
    
    private func showInbox(_ isInboxShown: Bool) {
        self.isInboxShown = isInboxShown
        inboxView.view.alpha = isInboxShown ? 1 : 0
        if isInboxShown {
            delegate?.imViewDidShowInbox(inboxView)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarImageView)
        } else {
            delegate?.imViewDidShowContacts(contactsView)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        }
    }
}
