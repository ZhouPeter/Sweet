//
//  ProfileController.swift
//  XPro
//
//  Created by 周鹏杰 on 2018/3/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import JXPhotoBrowser
protocol ProfileView: BaseView {
    var showAbout: ((UserResponse) -> Void)? { get set }
    var showStoriesPlayerView: (
        (
        User,
        [StoryCellViewModel],
        Int,
        StoriesPlayerGroupViewControllerDelegate?
        ) -> Void
        )? { get set }
    var finished: (() -> Void)? { get set }
    var user: User { get set }
    var userId: UInt64 { get set }
    var showConversation: ((User, User) -> Void)? { get set }
}

class ProfileController: BaseViewController, ProfileView {
    var showConversation: ((User, User) -> Void)?
    var showStoriesPlayerView: (
        (
        User,
        [StoryCellViewModel],
        Int,
        StoriesPlayerGroupViewControllerDelegate?
        ) -> Void
    )?
    var user: User
    var userId: UInt64
    let setTop: SetTop?
    var showAbout: ((UserResponse) -> Void)?
    var finished: (() -> Void)?
    var userResponse: UserResponse? {
        willSet {
            if let newValue = newValue {
                if newValue.userId == UInt64(Defaults[.userID] ?? "0") {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
                    navigationItem.title = "个人主页"
                } else {
                    navigationItem.title = "个人主页"
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: menuButton)
                }
            }
        }
    }
    private var photoBrowserImp: AvatarPhotoBrowserImp?
    private var actionsController: ActionsController?
    private var baseInfoViewModel: BaseInfoCellViewModel?
    private var isFirstLoad = true
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
        tableView.backgroundColor = UIColor(hex: 0xf2f2f2)
        tableView.register(UserInfoTableViewCell.self, forCellReuseIdentifier: "userInfoCell")
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
    
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.setImage(#imageLiteral(resourceName: "Back"), for: .normal)
        button.addTarget(self, action: #selector(returnAction(_:)), for: .touchUpInside)
        return button
    }()
    
    init(user: User, userId: UInt64, setTop: SetTop? = nil) {
        self.user = user
        self.userId = userId
        self.setTop = setTop
        super.init(nibName: nil, bundle: nil)
    }
    private var storage: Storage?

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        storage = Storage(userID: user.userId)
        setTableView()
        setBackButton()
    }
    
    func readLocalData() {
        storage?.read({ [weak self, userId] (realm) in
            guard let user = realm.object(ofType: UserData.self, forPrimaryKey: userId) else { return }
            self?.userResponse = UserResponse(data: user)
        }) { [weak self] in
            if self?.userResponse != nil { self?.loadTableView() }
        }
    }
    
    func saveUserData() {
        storage?.write({ [weak self] (realm) in
            guard let `self` = self, let userResponse = self.userResponse else { return }
           realm.create(UserData.self, value: UserData.data(with: userResponse), update: true)
        }) { (success) in
            if success {
                logger.debug("用户数据保存成功")
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        if userResponse == nil || !isFirstLoad {
            loadAll()
        } else {
            updateViewModel()
            tableView.reloadData()
            loadAll(isLoadUser: false)
        }
        if isFirstLoad { isFirstLoad = false }
    }
    
    private func setBackButton() {
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }
    
    @objc private func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
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
            let block = userResponse?.block,
            let subscription = userResponse?.subscription else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendMessageAction = UIAlertAction.makeAlertAction(title: "发送消息", style: .default) { [weak self] (_) in
            self?.sendMessage()
        }
        let subscriptionAction = UIAlertAction.makeAlertAction(
        title: subscription ? "取消订阅" : "订阅",
        style: .default) { [weak self] (_) in
            if subscription {
                self?.delUserSubscription(userId: userId)
            } else {
                self?.addUserSubscription(userId: userId)
            }
        }
        let shieldAction = UIAlertAction.makeAlertAction(
            title: block ? "取消屏蔽" : "屏蔽",
            style: .default) { [weak self] (_) in
            if block {
                self?.delUserBlock(userId: userId)
            } else {
                self?.addUserBlock(userId: userId)
            }
        }
        let addBlacklistAction = UIAlertAction.makeAlertAction(
            title: blacklist ? "移出黑名单" : "加入黑名单",
            style: .default) { [weak self] (_) in
            if blacklist {
                self?.delUserBlacklist(userId: userId)
            } else {
                self?.addUserBlacklist(userId: userId)
            }
        }
        let cancelAction = UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil)
        alertController.addAction(sendMessageAction)
        alertController.addAction(subscriptionAction)
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
    private func loadTableView() {
        if self.actionsController == nil {
            self.actionsController = ActionsController(user: User(self.userResponse!),
                                                       mine: self.user,
                                                       setTop: self.setTop)
            self.actionsController?.actionsDelegate = self
            self.actionsController!.showStoriesPlayerView = self.showStoriesPlayerView
            self.add(childViewController: self.actionsController!, addView: false)
        }
        self.saveUserData()
        self.updateViewModel()
        self.tableView.reloadData()
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
               self.loadTableView()
            }
        }
    }
    
    private func loadUserData(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        web.request(.getUserProfile(userId: self.userId), responseType: Response<ProfileResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.userResponse = response.userProfile
                completion?(true)
            case let .failure(error):
                logger.error(error)
                self.readLocalData()
                completion?(false)
            }
        }
    }

    private func updateViewModel() {
        baseInfoViewModel = BaseInfoCellViewModel(user: userResponse!)
    }
    
    private func sendMessage() {
        if let buddy = userResponse {
            showConversation?(user, User(buddy))
        }
    }

    private func delUserBlock(userId: UInt64) {
        web.request(.delBlock(userId: userId), completion: { (result) in
            switch result {
            case let .failure(error):
                logger.debug(error)
            case .success:
                self.userResponse?.block = false
            }
        })
    }
    
    private func addUserBlock(userId: UInt64) {
        web.request(.addBlock(userId: userId), completion: { (result) in
            switch result {
            case let .failure(error):
                logger.debug(error)
            case .success:
                self.userResponse?.block = true
            }
        })
    }
    
    private func delUserBlacklist(userId: UInt64) {
        web.request(.delBlacklist(userId: userId), completion: {  (result) in
            switch result {
            case let .failure(error):
                logger.debug(error)
            case .success:
                self.userResponse?.blacklist = false
            }
        })
    }
    
    private func addUserBlacklist(userId: UInt64) {
        web.request(.addBlacklist(userId: userId), completion: { (result) in
            switch result {
            case let .failure(error):
                logger.debug(error)
            case .success:
                self.userResponse?.blacklist = true
            }
        })
    }
    
    private func delUserSubscription(userId: UInt64) {
        web.request(
            .delUserSubscription(userId: userId),
            completion: { (result) in
                switch result {
                case .success:
                    self.userResponse!.subscription = false
                case let .failure(error):
                    logger.error(error)
                }
        })
    }
    
    private func addUserSubscription(userId: UInt64) {
        web.request(
            .addUserSubscription(userId: userId),
            completion: { (result) in
                switch result {
                case .success:
                    self.userResponse!.subscription = true
                case let .failure(error):
                    logger.error(error)
                }
        })
    }
 
}


extension ProfileController: ActionsControllerDelegate {
    func actionsScrollViewDidScoll(scrollView: UIScrollView) {
        if tableView.contentOffset.y < 244 - UIScreen.navBarHeight() {
            let newOffsetY = min(max(tableView.contentOffset.y + scrollView.contentOffset.y,
                                     -UIScreen.navBarHeight()),
                                 244 - UIScreen.navBarHeight())
            tableView.contentOffset.y = newOffsetY
            scrollView.contentOffset.y = 0
            let point = scrollView.panGestureRecognizer.translation(in: nil)
            if point.y > 0 && tableView.contentOffset.y > (244 - UIScreen.navBarHeight()) / 4 {

                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.tableView.contentOffset.y = -UIScreen.navBarHeight()
                }, completion: nil)
            }
        } else if tableView.contentOffset.y == 244 - UIScreen.navBarHeight() && scrollView.contentOffset.y < 0 {
            let newOffsetY = min(max(tableView.contentOffset.y + scrollView.contentOffset.y,
                                     -UIScreen.navBarHeight()),
                                 244 - UIScreen.navBarHeight())
            tableView.contentOffset.y = newOffsetY
            scrollView.contentOffset.y = 0
        }
    }
}
// MARK: - UITableViewDelegate

extension ProfileController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let point = scrollView.panGestureRecognizer.translation(in: nil)
        if point.y < 0 {
            if let actionsController = actionsController {
                var isEnableScroll = false
                for controller in actionsController.pageControllers {
                    if controller.cellNumber > 0 {
                        isEnableScroll = true
                        break
                    }
                }
                if !isEnableScroll {
                    scrollView.contentOffset.y = -UIScreen.navBarHeight()
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        guard  let viewModel = baseInfoViewModel else { return 0 }
        if indexPath.row == 0 {
            return viewModel.cellHeight
        } else {
            return UIScreen.mainHeight() - UIScreen.navBarHeight()
        }
    }
}

// MARK: - UITableViewDataSource

extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (baseInfoViewModel == nil || actionsController == nil) ? 0 : 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
           guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "userInfoCell",
                for: indexPath) as? UserInfoTableViewCell else { fatalError() }
            cell.delegate = self
            if let viewModel = baseInfoViewModel {
                cell.updateWith(viewModel)
            }
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "actionsCell",
                for: indexPath) as? ActionsTableViewCell else { fatalError() }
           cell.delegate = self
            if let view = actionsController?.view {
                cell.setPlaceholderContentView(view: view)
            }
           return cell
        }
    }
}

extension ProfileController: UserInfoTableViewCellDelegate {
    func didPressAvatarImageView(_ imageView: UIImageView, highURL: URL) {
        if user.userId == userId {
            let controller = UpdateAvatarController(avatar: highURL.absoluteString)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            photoBrowserImp = AvatarPhotoBrowserImp(thumbnaiImageViews: [imageView], highImageViewURLs: [highURL])
            let browser = CustomPhotoBrowser(delegate: photoBrowserImp!, originPageIndex: 0)
            browser.animationType = .scale
            browser.plugins.append(CustomNumberPageControlPlugin())
            browser.show()
        }
    }
    
    func editSignature() {
        let controller = UpdateSignatureController(signature: userResponse!.signature)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileController: ActionsTableViewCellDelegate {
    func selectedAction(at index: Int) {
        actionsController?.scrollToPage(.at(index: index), animated: true)
    }
}
