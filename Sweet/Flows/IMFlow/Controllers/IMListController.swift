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
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        imageView.addGestureRecognizer(tap)
        DispatchQueue.main.async {
            self.storage.read({ (realm) in
                if let user = realm.object(ofType: User.self, forPrimaryKey: Defaults[.userID]) {
                    imageView.kf.setImage(with: URL(string: user.avatarURLString + "?imageView2/1/w/30/h/30"))
                }
            })
        }
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarImageView)

    }
    @objc private func showProfile(_ sender: UITapGestureRecognizer) {
        showProfile?()
    }
}
