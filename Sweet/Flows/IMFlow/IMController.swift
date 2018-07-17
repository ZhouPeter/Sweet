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
    
    private lazy var titleView: CustomSegmentedControl = {
        let control = CustomSegmentedControl(items: ["消息", "联系人"])
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
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(scrollToPage(_:)),
                                               name: Notification.Name.ScrollToPage,
                                               object: nil)
        setupLeftBarButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let colors = [UIColor(hex: 0xDD9AFD), UIColor(hex: 0xB861FB)]
        navigationController?.navigationBar.setBackgroundGradientImage(colors: colors)
        navigationController?.navigationBar.barStyle = .black
        navigationController?.navigationBar.shadowImage = UIImage(named: "Separator")
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
    
    private func setupLeftBarButton() {
        var image = #imageLiteral(resourceName: "RightArrow")
        if let cgImage = image.cgImage {
            image = UIImage(cgImage: cgImage, scale: image.scale, orientation: .upMirrored)
        }
        let button = UIButton(type: .custom)
        button.setImage(image, for: .normal)
        button.bounds = CGRect(origin: .zero, size: CGSize(width: 30, height: 30))
        button.addTarget(self, action: #selector(didPressLeftBarButtonItem), for: .touchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
    }
    
    private func setupControllers() {
        add(childViewController: contactsView)
        contactsView.view.fill(in: view)
        add(childViewController: inboxView)
        inboxView.view.fill(in: view)
    }
    
    @objc private func switchView(_ control: CustomSegmentedControl) {
        showInbox(control.selectedSegmentIndex == 0)
    }
    
    @objc private func didPressRightBarButton() {
        if isInboxShown {
            delegate?.imViewDidPressAvatarButton()
        } else {
            delegate?.imViewDidPressSearchButton()
        }
    }
    
    @objc func didPressLeftBarButtonItem() {
        NotificationCenter.default.post(name: .ScrollPage, object: 1)
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
    
    @objc private func scrollToPage(_ noti: Notification) {
        if let object = noti.object as? [String: Any], let index = object["index"] as? Int {
            if  index == 2 {
                titleView.selectedSegmentIndex = 0
                showInbox(true)
            }
        }
    }
}
