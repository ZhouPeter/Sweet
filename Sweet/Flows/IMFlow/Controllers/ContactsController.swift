//
//  ContactsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

private let contactsButtonWidth: CGFloat = 44
private let contactsButtonHeight: CGFloat = 60
private let buttonSpace: CGFloat = 50

class ContactsController: BaseViewController, ContactsView {
    weak var delegate: ContactsViewDelegate?
    
    private var blacklistViewModels = [ContactViewModel]()
    private var between72hViewModels = [ContactViewModel]()
    private var allViewModels = [ContactViewModel]()
    private var titles = [String]()
    
    private lazy var categoryViewModels: [ContactCategoryViewModel] = {
        var viewModels = [ContactCategoryViewModel]()
        let addViewModel = ContactCategoryViewModel(categoryImage: #imageLiteral(resourceName: "AddFriend"), title: "邀请好友")
        viewModels.append(addViewModel)
        let subViewModel = ContactCategoryViewModel(categoryImage: #imageLiteral(resourceName: "Subscribe"), title: "订阅")
        viewModels.append(subViewModel)
        return viewModels
    } ()
    
    private var viewModelsGroup = [[ContactViewModel]]() {
        didSet {
            self.showEmptyView(isShow: self.viewModelsGroup.count == 0)
        }
    }
    
    private lazy var tableViewFooterView: ContactsFooterView = {
        let view = ContactsFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainWidth(), height: 45))
        return view
    } ()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactsCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.tableFooterView = tableViewFooterView
        return tableView
    } ()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "SearchWhite"), for: .normal)
        button.addTarget(self, action: #selector(showSearch(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    } ()
    
    private lazy var emptyView: EmptyEmojiView = {
        let view = EmptyEmojiView()
        return view
    } ()
    
    // MARK: - Private
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        view.addSubview(tableView)
        tableView.fill(in: view, left: 0, right: 0, top: UIScreen.navBarHeight(), bottom: UIScreen.safeBottomMargin())
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)
        loadContactAllList()
    }
    
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            tableView.addSubview(emptyView)
            emptyView.frame = CGRect(
                x: 0,
                y: 8 + 80 * 2,
                width: tableView.bounds.width,
                height: tableView.bounds.height - (8 + 80 * 2) + 1
            )
        } else {
            emptyView.removeFromSuperview()
        }
    }
    
    private func removeData() {
        allViewModels.removeAll()
        between72hViewModels.removeAll()
        blacklistViewModels.removeAll()
        viewModelsGroup.removeAll()
        titles.removeAll()
    }
    
    private func loadContactAllList() {
        web.request(.contactAllList, responseType: Response<ContactListResponse>.self) {[weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                self.removeData()
                let models = response.list
                models.forEach({ (model) in
                    let viewModel = ContactViewModel(model: model)
                    self.allViewModels.append(viewModel)
                    if model.lastTime > Int(Date().timeIntervalSince1970 * 1000 - 3600 * 72) {
                        self.between72hViewModels.append(viewModel)
                    }
                })
                let blacklistModels = response.blacklist
                blacklistModels.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        web.request(.delBlacklist(userId: userId), completion: { (result) in
                            switch result {
                            case let .failure(error):
                                logger.error(error)
                            case .success:
                                self?.delBlacklist(userId: userId)
                            }
                        })
                    }
                    self.blacklistViewModels.append(viewModel)
                })
                self.between72hViewModels.sort {
                     return $0.lastTime > $1.lastTime
                }
                if self.between72hViewModels.count > 0 {
                    self.viewModelsGroup.append(self.between72hViewModels)
                    self.titles.append("最近联系")
                }
                if self.allViewModels.count > 0 {
                    self.viewModelsGroup.append(self.allViewModels)
                    self.titles.append("全部")
                }
                if self.blacklistViewModels.count > 0 {
                    self.viewModelsGroup.append(self.blacklistViewModels)
                    self.titles.append("黑名单")
                }
                let countTitle = "\(self.allViewModels.count + self.blacklistViewModels.count)位联系人"
                self.tableViewFooterView.update(title: countTitle)
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delBlacklist(userId: UInt64) {
        web.request(.delBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blacklistViewModels.index(where: { $0.userId == userId }) else { return }
                self.blacklistViewModels[index].buttonStyle = .backgroundColorGray
                self.blacklistViewModels[index].buttonTitle = "拉黑"
                self.blacklistViewModels[index].callBack = { [weak self] userId in
                    self?.addBlacklist(userId: userId)
                }
                let indexPath = IndexPath(row: index, section: self.tableView.numberOfSections - 1)
                self.viewModelsGroup[indexPath.section][index] = self.blacklistViewModels[index]
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addBlacklist(userId: UInt64) {
        web.request(.addBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blacklistViewModels.index(where: { $0.userId == userId }) else { return }
                self.blacklistViewModels[index].buttonStyle = .borderGray
                self.blacklistViewModels[index].buttonTitle = "恢复"
                self.blacklistViewModels[index].callBack = { [weak self] userId in
                    self?.delBlacklist(userId: userId)
                }
                let indexPath = IndexPath(row: index, section: self.tableView.numberOfSections - 1)
                self.viewModelsGroup[indexPath.section][index] = self.blacklistViewModels[index]
                self.tableView.reloadRows(at: [indexPath], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }

    // MARK: - Actions
    
    @objc private func showSearch(_ sender: UIButton) {
        delegate?.contactsShowSearch()
    }
}

extension ContactsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
        view?.update(title: section == 0 ? "" : titles[section - 1])
        return view
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 8
        } else {
            return 25
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                delegate?.contactsShowInvite()
            } else {
                delegate?.contactsShowSubscription()
            }
        } else {
            let userID = viewModelsGroup[indexPath.section - 1][indexPath.row].userId
            delegate?.contactsShowProfile(userID: userID)
        }
    }
}

extension ContactsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModelsGroup.count + 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 2 : viewModelsGroup[section - 1].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "contactsCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        if indexPath.section == 0 {
            cell.updateCategroy(viewModel: categoryViewModels[indexPath.row])
        } else {
            cell.update(viewModel: viewModelsGroup[indexPath.section - 1][indexPath.row])
        }
        return cell
        
    }
}