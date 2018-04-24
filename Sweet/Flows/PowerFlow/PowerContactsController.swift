//
//  PowerContactsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Contacts
class PowerContactsController: BaseViewController, PowerContactsView {
    var onFinish: (() -> Void)?
    
    var showPush: (() -> Void)?
    var contactsUpload = false
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 30)
        label.textColor = .black
        label.text = "找到“讲真”上的好友"
        label.textAlignment = .center
        return label
    }()
    
    private lazy var subtitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.xpTextGray()
        label.text = "请允许我们访问你的通讯录，以便你们快速的找到彼此，掌握好友的最新动态，“匿名投票”给好友。"
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var doneButton: ShrinkButton = {
        let button = ShrinkButton()
        button.setTitle("好的", for: .normal)
        button.backgroundColor = UIColor.xpBlue()
        button.addTarget(self, action: #selector(doneAction), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "请允许"
        navigationController?.navigationBar.barTintColor = UIColor.xpGray()
        navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedStringKey.foregroundColor: UIColor.black]
        NotificationCenter.default.addObserver(self,
                            selector: #selector(becomeAction),
                                name: .UIApplicationDidBecomeActive,
                              object: nil)
        setupUI()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: .UIApplicationDidBecomeActive,
                                                  object: nil)
    }

}

// MARK: - Actions
extension PowerContactsController {
    @objc private func becomeAction() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .authorized {
            if !contactsUpload {
                getContacts()
            }
        }
    }
    @objc private func doneAction() {
        showAlertWithContactStates()
    }
}

// MARK: - Privates
extension PowerContactsController {
    private func setupUI() {
        view.addSubview(titleLabel)
        titleLabel.center(to: view, offsetY: -100)
        view.addSubview(subtitleLabel)
        subtitleLabel.align(.left, to: view, inset: 28)
        subtitleLabel.align(.right, to: view, inset: 28)
        subtitleLabel.pin(to: titleLabel, edge: .bottom, spacing: -28)
        view.addSubview(doneButton)
        doneButton.align(.left, to: view, inset: 28)
        doneButton.align(.right, to: view, inset: 28)
        doneButton.pin(to: subtitleLabel, edge: .bottom, spacing: -20)
        doneButton.constrain(height: 50)
        doneButton.setViewRounded()
    }
    
    private func showNextController() {
        DispatchQueue.main.async {
            guard let settings = UIApplication.shared.currentUserNotificationSettings
                else { return }
            if settings.types == [] {
                self.showPush?()
            } else {
                self.onFinish?()
            }
        }
    }
    
    private func showAlertWithContactStates() {
        let status = CNContactStore.authorizationStatus(for: .contacts)
        if status == .notDetermined {
            let store = CNContactStore()
            store.requestAccess(for: .contacts) { (granted, _) in
                if granted { self.getContacts() }
            }
        } else if status == .denied {
            let message = "讲真无法为你匹配通讯录好友，将影响您的使用体验，请您开启该权限"
            let alertController = UIAlertController(
                                                    title: "您未允许访问通讯录",
                                                    message: message,
                                                    preferredStyle: .alert)
            let settingAction = UIAlertAction(title: "去设置", style: .cancel) { [weak self] (_) in
                self?.openApplicationSetting()
            }
            alertController.addAction(settingAction)
            present(alertController, animated: true, completion: nil)
        } else if status == .authorized {
            showNextController()
        }
    }
    
    private func openApplicationSetting() {
        let url = URL(string: UIApplicationOpenSettingsURLString)!
        if UIApplication.shared.canOpenURL(url) {
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    private func getContacts() {
        let contacts = Contacts.getContacts()
        uploadContacts(contacts: contacts)
    }
    
    private func uploadContacts(contacts: [[String: Any]]) {
        if contactsUpload { return }
        web.request(.uploadContacts(contacts: contacts)) { (result) in
            switch result {
            case .success:
                self.contactsUpload = true
                self.showNextController()
            case let .failure(error):
                logger.error(error)
            }
        }
        
    }
}
