//
//  IMManagerController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol IMView: BaseView {
    var didShowInbox: ((InboxView) -> Void)? { get set }
    var didShowContacts: ((ContactsView) -> Void)? { get set }
}

class IMController: BaseViewController, IMView {
    var didShowInbox: ((InboxView) -> Void)?
    var didShowContacts: ((ContactsView) -> Void)?
    
    private var inboxController = InboxController()
    private var contactsController = ContactsController()
    private var isConversationsShown = true
    
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
        setupControllers()
        didShowInbox?(inboxController)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = UIColor.xpNavBlue()
        navigationController?.navigationBar.barStyle = .black
    }
    
    // MARK: - Private
    
    private func setupControllers() {
        add(childViewController: contactsController)
        contactsController.view.fill(in: view)
        add(childViewController: inboxController)
        inboxController.view.fill(in: view)
    }
    
    @objc private func switchView(_ control: UISegmentedControl) {
        showContacts(control.selectedSegmentIndex == 1)
    }
    
    private func showContacts(_ isContacts: Bool) {
        inboxController.view.alpha = isContacts ? 0 : 1
        if isContacts {
            didShowContacts?(contactsController)
        } else {
            didShowInbox?(inboxController)
        }
    }
}
