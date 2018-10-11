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
    var delegate: ProfileViewDelegate? { get set }
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
    var showStory: (() -> Void)? { get set }
    var showProfile: ((UInt64, SetTop?, (() -> Void)?) -> Void)? { get set }
}

protocol ProfileViewDelegate: class {
    func showAbout(user: UserResponse, updateRemain: UpdateRemainResponse, setting: UserSetting)
    func showConversation(user: User, buddy: User)
    func showLikeRankList(title: String)
}

class ProfileController: BaseViewController, ProfileView {
    
    weak var delegate: ProfileViewDelegate?
    private var userScrollFlag = false
    var showStory: (() -> Void)?
    var showProfile: ((UInt64, SetTop?, (() -> Void)?) -> Void)?
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
    var finished: (() -> Void)?
    var userResponse: UserResponse? {
        willSet {
            if let newValue = newValue {
                DispatchQueue.main.async {
                    if  let IDString = Defaults[.userID],
                        let userID = UInt64(IDString),
                        newValue.userId == userID {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.moreButton)
                    } else {
                        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: self.menuButton)
                    }
                }
            }
        }
    }
    
    private var updateRemain: UpdateRemainResponse?
    private var setting: UserSetting?
    private var photoBrowserImp: AvatarPhotoBrowserImp?
    private var actionsController: ActionsController?
    private var baseInfoViewModel: BaseInfoCellViewModel?
    private var isReadLocal = false
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
        button.tintColor = .black
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: -40, bottom: 0, right: 0)
        button.setImage(#imageLiteral(resourceName: "LeftArrow").withRenderingMode(.alwaysTemplate), for: .normal)
        button.addTarget(self, action: #selector(returnAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var avatarView: UIView = {
        let view = UIView()
        view.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        let imageView = UIImageView()
        imageView.sd_setImage(with: URL(string: userResponse!.avatar))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        view.addSubview(imageView)
        view.layer.cornerRadius = 15
        view.clipsToBounds = true
        return view
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
        navigationItem.title = "主页"
        contentSizeInPopup = CGSize(width: UIScreen.mainWidth(), height: UIScreen.mainHeight())
        storage = Storage(userID: user.userId)
        setTableView()
        setBackButton()
        loadAll()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setNavigationBar()
        let offsetY = tableView.contentOffset.y
        DispatchQueue.main.async {
            self.tableView.contentOffset.y = offsetY
        }
        if isReadLocal {
            readLocalData()
            isReadLocal = false
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    private func setNavigationBar() {
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
       
    }
    
    deinit {
        logger.debug("个人页释放")
    }
    
    func readLocalData() {
        storage?.read({ [weak self, userId] (realm) in
            guard let user = realm.object(ofType: UserData.self, forPrimaryKey: userId) else { return }
            self?.userResponse = UserResponse(data: user)
        }) { [weak self] in
            if self?.userResponse != nil { self?.loadTableView() }
        }
        
        storage?.read({ [weak self, userId] (realm) in
            guard let `self` = self else { return }
            guard let setting = realm.object(ofType: SettingData.self, forPrimaryKey: userId) else { return}
            self.setting = UserSetting(data: setting)
        })
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
    
    func saveUserSetting() {
        storage?.write({ [weak self] (realm) in
            guard let `self` = self, let setting = self.setting else { return }
            realm.create(SettingData.self, value: SettingData.data(with: setting), update: true)
        })
    }
    private func setBackButton() {
        if navigationController?.viewControllers.count == 1 {
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
        }
    }
    
    @objc private func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
        finished?()
    }
    
    override func didMove(toParentViewController parent: UIViewController?) {
        super.didMove(toParentViewController: parent)
        if parent == nil {
            finished?()
        }
    }
}

// MARK: - Actions

extension ProfileController {
    @objc private func moreAction(sender: UIButton) {
        guard let user = userResponse, let updateRemain = updateRemain, let setting = setting else { return }
        isReadLocal = true
        delegate?.showAbout(user: user, updateRemain: updateRemain, setting: setting)
    }
    
    @objc private func menuAction(sender: UIButton) {
        guard let userId = userResponse?.userId,
            let blacklist = userResponse?.blacklist else { return }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let sendMessageAction = UIAlertAction.makeAlertAction(title: "发送消息", style: .default) { [weak self] (_) in
            self?.sendMessage()
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
        if actionsController == nil {
            actionsController = ActionsController(user: User(userResponse!),
                                                       mine: user,
                                                       setTop: setTop)
            actionsController!.actionsDelegate = self
            actionsController!.showStoriesPlayerView = showStoriesPlayerView
            actionsController!.showStory = showStory
            actionsController?.showProfile = showProfile
            add(childViewController: actionsController!, addView: false)
        }
        saveUserData()
        saveUserSetting()
        updateViewModel()
        tableView.reloadData()
        let offsetY = tableView.contentOffset.y
        DispatchQueue.main.async {
            self.tableView.contentOffset.y = offsetY
        }
      
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
        if user.userId == userId {
            group.enter()
            queue.async {
                self.loadUpdateRemain(completion: { (isSuccess) in
                    group.leave()
                })
            }
        }
        group.notify(queue: DispatchQueue.main) {
            if userSuccess {
               self.loadTableView()
            }
        }
    }
    
    private func loadUpdateRemain(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        web.request(.updateRemain, responseType: Response<UpdateRemainResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.updateRemain = response
                completion?(true)
            case let .failure(error):
                completion?(false)
                logger.error(error)
            }
        }
    }
    private func loadUserData(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        web.request(.getUserProfile(userId: self.userId), responseType: Response<ProfileResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.userResponse = response.userProfile
                self.setting = response.setting
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
            delegate?.showConversation(user: user, buddy: User(buddy))
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
    func actionsSrollViewDidScrollToBottom(scrollView: UIScrollView, index: Int) {
        guard  let viewModel = baseInfoViewModel else { return }
        let infoHeight = viewModel.cellHeight
        let contentHeight = scrollView.contentSize.height
        let contentVisibleHeight = UIScreen.mainHeight() - UIScreen.navBarHeight() - infoHeight - 50
        if contentHeight <= contentVisibleHeight {
            return
        } else {
            let cellHeight = (UIScreen.mainHeight() - 6) / 3
            let lineCount = CGFloat(ceil(CGFloat(index + 1) / 3.0))
            let contentMaxVisibleHeight = UIScreen.mainHeight() - UIScreen.navBarHeight() - 50
            let cellSumHeight = cellHeight * lineCount + 3 * (lineCount - 1)
            var scrollViewOffsetY = cellSumHeight - scrollView.frame.height
            if cellSumHeight <= contentMaxVisibleHeight {
                scrollViewOffsetY = max(0, scrollViewOffsetY)
            }
            if scrollView.bounds.origin.y != scrollViewOffsetY {
                let point = CGPoint(x: 0, y: scrollViewOffsetY)
                let bounds = CGRect(origin: point, size: scrollView.bounds.size)
                scrollView.bounds = bounds
            }
            let tableViewOffsetY = min(max(cellSumHeight - contentVisibleHeight, 0), infoHeight)
            if self.tableView.bounds.origin.y != tableViewOffsetY - UIScreen.navBarHeight() {
                let point = CGPoint(x: 0, y: tableViewOffsetY - UIScreen.navBarHeight())
                let bounds = CGRect(origin: point, size: tableView.bounds.size)
                tableView.bounds = bounds
            }
        }
    }
    
    func actionsScrollViewDidScroll(scrollView: UIScrollView) {
        guard  let viewModel = baseInfoViewModel else { return }
        let infoHeight = viewModel.cellHeight
        navigationItem.titleView = nil
        if tableView.contentOffset.y < infoHeight - UIScreen.navBarHeight() {
            let newOffsetY = min(max(tableView.contentOffset.y + scrollView.contentOffset.y,
                                     -UIScreen.navBarHeight()),
                                 infoHeight - UIScreen.navBarHeight())
            tableView.contentOffset.y = newOffsetY
            scrollView.contentOffset.y = 0
            let point = scrollView.panGestureRecognizer.translation(in: nil)
            if point.y > 0
                && tableView.contentOffset.y > (infoHeight - UIScreen.navBarHeight()) / 4 {
                UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                    self.tableView.contentOffset.y = -UIScreen.navBarHeight()
                }, completion: nil)
            }
        } else if tableView.contentOffset.y == infoHeight - UIScreen.navBarHeight() {
            if scrollView.contentOffset.y < 0 {
                let newOffsetY = min(max(tableView.contentOffset.y + scrollView.contentOffset.y,
                                         -UIScreen.navBarHeight()),
                                     infoHeight - UIScreen.navBarHeight())
                tableView.contentOffset.y = newOffsetY
                scrollView.contentOffset.y = 0
            }
            navigationItem.titleView = avatarView
        }
    }
}
// MARK: - UITableViewDelegate

extension ProfileController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard  let viewModel = baseInfoViewModel else { return }
        let infoHeight = viewModel.cellHeight
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
        } else if point.y > 0 && scrollView.contentOffset.y > (infoHeight - UIScreen.navBarHeight()) / 4 {
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseOut, animations: {
                scrollView.contentOffset.y = -UIScreen.navBarHeight()
            }, completion: nil)
        }
        if  scrollView.contentOffset.y == infoHeight - UIScreen.navBarHeight() {
            navigationItem.titleView = avatarView
        } else if scrollView.contentOffset.y > infoHeight - UIScreen.navBarHeight() {
            scrollView.contentOffset.y = infoHeight - UIScreen.navBarHeight()
            navigationItem.titleView = avatarView
        } else {
            navigationItem.titleView = nil
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
            if user.userId == userId {
                cell.update(activityTitle: "动态 \(userResponse!.activityNum)", storyTitle: "小故事 \(userResponse!.storyNum)")
            } else {
                cell.update(activityTitle: "共同喜欢 \(userResponse!.activityNum)", storyTitle: "小故事 \(userResponse!.storyNum)")
            }
           cell.delegate = self
            if let view = actionsController?.view {
                cell.setPlaceholderContentView(view: view)
            }
           return cell
        }
    }
}

extension ProfileController: UserInfoTableViewCellDelegate {
    func showLikeRankList() {
        delegate?.showLikeRankList(title: userResponse!.universityName + "❤️优秀榜")
    }
    
    func didPressAvatarImageView(_ imageView: UIImageView, highURL: URL) {
        if user.userId == userId {
            isReadLocal = true
            let controller = UpdateAvatarController(avatar: highURL.absoluteString)
            navigationController?.pushViewController(controller, animated: true)
        } else {
            photoBrowserImp = AvatarPhotoBrowserImp(thumbnaiImageViews: [imageView], highImageViewURLs: [highURL])
            let browser = CustomPhotoBrowser(delegate: photoBrowserImp!,
                                             photoLoader: SDWebImagePhotoLoader(),
                                             originPageIndex: 0)
            browser.animationType = .scale
            browser.plugins.append(CustomNumberPageControlPlugin())
            browser.show()
        }
    }
    
    func editSignature() {
        isReadLocal = true
        let controller = UpdateSignatureController(signature: userResponse!.signature)
        navigationController?.pushViewController(controller, animated: true)
    }
}

extension ProfileController: ActionsTableViewCellDelegate {
    func selectedAction(at index: Int) {
        actionsController?.scrollToPage(.at(index: index), animated: true)
    }
}
