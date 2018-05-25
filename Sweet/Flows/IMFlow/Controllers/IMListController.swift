//
//  IMController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol IMListView: BaseView {
    var showProfile: (() -> Void)? { get set }
}
final class IMListController: BaseViewController, IMListView {
    var showProfile: (() -> Void)?
    
    let storage = Storage(userID: UInt64(Defaults[.userID]))
    private lazy var avatarButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.layer.cornerRadius = 15
        button.layer.masksToBounds = true
        button.addTarget(self, action: #selector(showProfile(_:)), for: .touchUpInside)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .green
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarButton)
        storage.read({ (realm) in
            if let user = realm.object(ofType: User.self, forPrimaryKey: Defaults[.userID]) {
                self.avatarButton.kf.setBackgroundImage(with: URL(string: user.avatarURLString), for: .normal)
            }
        })
    }
    @objc private func showProfile(_ sender: UIButton) {
        showProfile?()
    }
}
