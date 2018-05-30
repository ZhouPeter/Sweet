//
//  ConversationsController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol ConversationsView: BaseView {
    var showProfile: (() -> Void)? { get set }
    func didUpdateAvatar(URLString: String)
}

final class ConversationsController: BaseViewController, ConversationsView {
    var showProfile: (() -> Void)?
    
    private lazy var avatarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        imageView.layer.cornerRadius = 15
        imageView.layer.masksToBounds = true
        imageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer(target: self, action: #selector(showProfile(_:)))
        imageView.addGestureRecognizer(tap)
        return imageView
    } ()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: avatarImageView)
    }
    
    func didUpdateAvatar(URLString: String) {
        avatarImageView.kf.setImage(with: URL(string: URLString))
    }
    
    // MARK: - Private
    
    @objc private func showProfile(_ sender: UITapGestureRecognizer) {
        showProfile?()
    }
}