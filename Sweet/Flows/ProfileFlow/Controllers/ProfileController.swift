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
}
class ProfileController: BaseViewController, ProfileView {
    var showAbout: ((UserResponse) -> Void)?

    var user: UserResponse? {
        willSet {
            if let newValue = newValue {
                if newValue.userId == 12 {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
                    navigationItem.title = "我的"
                } else {
                    navigationItem.title = newValue.nickname
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setTableView()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: moreButton)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if user == nil || !isFirstLoad {
            loadAll()
        } else {
            updateViewModel()
            tableView.reloadData()
            loadAll(isLoadUser: false)
        }
        if isFirstLoad { isFirstLoad = false }
    }
}
// MARK: - Actions
extension ProfileController {
    @objc private func moreAction(sender: UIButton) {
        guard let userId = user?.userId, userId == Defaults[.userID] else { return }
        self.showAbout?(user!)
       
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
        let feedsSuccess: Bool = true
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
//        group.enter()
//        queue.async {
//            self.loadFeedsData(completion: { (isSuccess) in
//                group.leave()
//                feedsSuccess = isSuccess
//            })
//        }
        group.notify(queue: DispatchQueue.main) {
            if userSuccess && feedsSuccess {
                self.updateViewModel()
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadUserData(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let userId = (user != nil) ? user!.userId : UInt64(Defaults[.userID])
        web.request(.getUserProfile(userId: userId), responseType: Response<ProfileResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.user = response.userProfile
                completion?(true)
            case let .failure(error):
                logger.error(error)
                completion?(false)
            }
        }
    }
    
    private func loadFeedsData(completion: ((_ isSuccess: Bool) -> Void)? = nil) {
        let userId = (user != nil) ? user!.userId : UInt64(Defaults[.userID])
        
    }

    private func updateViewModel() {
        self.baseInfoViewModel = BaseInfoCellViewModel(user: user!)
    }
    
}
// MARK: - UITableViewDelegate
extension ProfileController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row == 0, let viewModel = baseInfoViewModel {
            return viewModel.cellHeight
        } else {
            return 450
        }
    }
    
}

// MARK: - UITableViewDataSource
extension ProfileController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
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
           actionsController = ActionsController()
           actionsController.userId = user?.userId
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
