//
//  ProfileController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/3/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults

protocol ProfileView: BaseView {
    var showAbout: ((UserResponse) -> Void)? { get set }
    var finished: (() -> Void)? { get set }
    var user: User? { get set }
    var userId: UInt64? { get set }
}

class ProfileController: BaseViewController, ProfileView {
    var user: User?
    var userId: UInt64?
    var showAbout: ((UserResponse) -> Void)?
    var finished: (() -> Void)?
    var userResponse: UserResponse? {
        willSet {
            if let newValue = newValue {
                if newValue.userId == UInt64(Defaults[.userID] ?? "0") {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
                    navigationItem.title = "我的"
                } else {
                    navigationItem.title = newValue.nickname
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
                }
            }
        }
    }
    
    var actionsController: ActionsController!
    
    private var baseInfoViewModel: BaseInfoCellViewModel?
    private var isFirstLoad = true

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: 0xf2f2f2)
        tableView.register(UINib(nibName: "BaseInfoTableViewCell", bundle: nil), forCellReuseIdentifier: "baseCell")
        tableView.register(ActionsTableViewCell.self, forCellReuseIdentifier: "actionsCell")
        tableView.backgroundColor = UIColor.xpGray()
        return tableView
    }()

    private lazy var moreButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "More"), for: .normal)
        button.addTarget(self, action: #selector(moreAction(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    private lazy var menuButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Menu_black"), for: .normal)
        button.addTarget(self, action: #selector(menuAction(sender:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        actionsController = ActionsController()
        addChildViewController(actionsController)
        actionsController.didMove(toParentViewController: self)
        setTableView()
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.tintColor = .black
        if userResponse == nil || !isFirstLoad {
            loadAll()
        } else {
            updateViewModel()
            tableView.reloadData()
            loadAll(isLoadUser: false)
        }
        if isFirstLoad { isFirstLoad = false }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        if parent == nil {
            finished?()
        }
    }
}

// MARK: - Actions

extension ProfileController {
    @objc private func moreAction(sender: UIButton) {
        guard let user = userResponse else { return }
        self.showAbout?(user)
    }
    
    @objc private func menuAction(sender: UIButton) {
        guard let userId = userResponse?.userId,
            let blacklist = userResponse?.blacklist,
            let block = userResponse?.block else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let shieldAction = UIAlertAction(
            title: block ? "取消屏蔽" : "屏蔽他/她的来源",
            style: .default) { [weak self] (_) in
            if block {
                web.request(.delBlock(userId: userId), completion: { (result) in
                    switch result {
                    case let .failure(error):
                        logger.debug(error)
                    case .success:
                        self?.userResponse?.block = !block
                    }
                })
            } else {
                web.request(.addBlock(userId: userId), completion: { (result) in
                    switch result {
                    case let .failure(error):
                        logger.debug(error)
                    case .success:
                        self?.userResponse?.block = !block
                    }
                })
            }
        }
        shieldAction.setTextColor(color: .black)
        let addBlacklistAction = UIAlertAction(
            title: blacklist ? "移出黑名单" : "加入黑名单",
            style: .default) { [weak self] (_) in
            if blacklist {
                web.request(.delBlacklist(userId: userId), completion: {  (result) in
                    switch result {
                    case let .failure(error):
                        logger.debug(error)
                    case .success:
                        self?.userResponse?.blacklist = !blacklist
                    }
                })
            } else {
                web.request(.addBlacklist(userId: userId), completion: { (result) in
                    switch result {
                    case let .failure(error):
                        logger.debug(error)
                    case .success:
                        self?.userResponse?.blacklist = !blacklist
                    }
                })
            }
        }
        addBlacklistAction.setTextColor(color: .black)
        let cancelAction = UIAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(shieldAction)
        alertController.addAction(addBlacklistAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Private Methods

extension ProfileController {
    private func setTableView() {
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    
    private func loadAll(isLoadUser: Bool = true) {
        let group = DispatchGroup()
        let queue = DispatchQueue.global()
        var userSuccess: Bool = false
        if isLoadUser {
            group.enter()
            queue.async {
                self.loadUserData(completion: { (isSuccess) in
                    group.leave()
                    userSuccess = isSuccess
                })
            }
        } else {
            userSuccess = true
        }
        group.notify(queue: DispatchQueue.main) {
            if userSuccess {
                self.actionsController.userId = self.userResponse?.userId
                self.updateViewModel()
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadUserData(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let userId = (self.userId == nil ? (UInt64(Defaults[.userID] ?? "0") ?? 0) : self.userId!)
        web.request(.getUserProfile(userId: userId), responseType: Response<ProfileResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.userResponse = response.userProfile
                completion?(true)
            case let .failure(error):
                logger.error(error)
                completion?(false)
            }
        }
    }

    private func updateViewModel() {
        self.baseInfoViewModel = BaseInfoCellViewModel(user: userResponse!)
        self.baseInfoViewModel?.subscribeAction = { [weak self] userId in
            guard let `self` = self, let subscription = self.userResponse?.subscription else { return }
            web.request(
                subscription ?
                    .delUserSubscription(userId: userId) : .addUserSubscription(userId: userId),
                completion: { (result) in
                switch result {
                case .success:
                    self.userResponse!.subscription = !self.userResponse!.subscription
                    self.baseInfoViewModel?.subscribeButtonString
                        = self.userResponse!.subscription ? "已订阅" : "订阅"
                    self.tableView.reloadRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                case let .failure(error):
                    logger.error(error)
                }
            })
        }
        self.baseInfoViewModel?.sendMessageAction = { [weak self] in
            if let user = self?.user, let buddy = self?.userResponse {
                let conversationController = ConversationController(user: user, buddy: User(buddy))
                self?.navigationController?.pushViewController(conversationController, animated: true)
            }
        }
    }
    
}

// MARK: - UITableViewDelegate

extension ProfileController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard  let viewModel = baseInfoViewModel else { return 0 }
        if indexPath.row == 0 {
            return viewModel.cellHeight
        } else {
            return UIScreen.mainHeight() - viewModel.cellHeight - UIScreen.navBarHeight()
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return baseInfoViewModel == nil ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
           guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "baseCell",
                for: indexPath) as? BaseInfoTableViewCell else { fatalError() }
            if let viewModel = baseInfoViewModel {
                cell.updateWith(viewModel)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "actionsCell",
                for: indexPath) as? ActionsTableViewCell else { fatalError() }
           cell.delegate = self
           cell.setPlaceholderContentView(view: actionsController.view)
           return cell
        }
    }
}

extension ProfileController: ActionsTableViewCellDelegate {
    func selectedAction(at index: Int) {
        actionsController.scrollToPage(.at(index: index), animated: true)
    }
}
