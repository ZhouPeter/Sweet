//
//  ContactSearchController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol ContactSearchView: BaseView {
    var back:(() -> Void)? { get set }
    var showProfile: ((UInt64) -> Void)? { get set }
}

class ContactSearchController: BaseViewController, ContactSearchView {
    var back: (() -> Void)?
    var showProfile: ((UInt64) -> Void)?
    var contactViewModels = [ContactViewModel]()
    var subscriptionsViewModels = [ContactViewModel]()
    var blacklistViewModels = [ContactViewModel]()
    var blockViewModels = [ContactViewModel]()
    var phoneContactViewModels = [PhoneContactViewModel]()
    var titles = [String]()
    private var lastestSearchText: String = ""
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 44, height: 30)
        button.setTitle("返回", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 20)
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth() - 75, height: 25)
        searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchBar.placeholder = "搜索人名、手机号"
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.keyboardDismissMode = .onDrag
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        return tableView
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: backButton)
        navigationItem.hidesBackButton = true
        navigationItem.titleView = searchBar
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    @objc private func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    private func removeAllData() {
        contactViewModels.removeAll()
        subscriptionsViewModels.removeAll()
        phoneContactViewModels.removeAll()
        blockViewModels.removeAll()
        blacklistViewModels.removeAll()
        titles.removeAll()
    }
    private func searchContact(name: String) {
        if name == "" {
            removeAllData()
            tableView.reloadData()
            return
        }
        web.request(.searchContact(name: name), responseType: Response<SearchContactResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.removeAllData()
                response.contacts.forEach({ (model) in
                    let viewModel = ContactViewModel(model: model)
                    self.contactViewModels.append(viewModel)
                })
                response.subscriptions.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "已订阅", style: .borderBlue)
                    viewModel.callBack = { [weak self] userId in
                        self?.delSubscription(userId: userId)
                    }
                    self.subscriptionsViewModels.append(viewModel)
                })
                response.phoneContacts.forEach({ (model) in
                    var viewModel = PhoneContactViewModel(model: model)
                    viewModel.callBack = { [weak self] phone in
                        self?.invitePhoneContact(phone: String(phone))
                    }
                    self.phoneContactViewModels.append(viewModel)
                })
                response.blocks.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlock(userId: userId)
                    }
                    self.blockViewModels.append(viewModel)
                })
                response.blacklists.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlacklist(userId: userId)
                    }
                    self.blacklistViewModels.append(viewModel)
                })
                if self.contactViewModels.count > 0 { self.titles.append("联系人") }
                if self.subscriptionsViewModels.count > 0 { self.titles.append("订阅") }
                if self.phoneContactViewModels.count > 0 { self.titles.append("通讯录") }
                if self.blockViewModels.count > 0 { self.titles.append("屏蔽") }
                if self.blacklistViewModels.count > 0 { self.titles.append("黑名单") }

                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }

    private func delBlock(userId: UInt64) {
        web.request(.delBlock(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blockViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "屏蔽"}) else { return }
                self.blockViewModels[index].buttonTitle = "屏蔽"
                self.blockViewModels[index].buttonStyle = .backgroundColorGray
                self.blockViewModels[index].callBack = { [weak self] userId in
                    self?.addBlock(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addBlock(userId: UInt64) {
        web.request(.addBlock(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blockViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "屏蔽"}) else { return }
                self.blockViewModels[index].buttonTitle = "恢复"
                self.blockViewModels[index].buttonStyle = .borderGray
                self.blockViewModels[index].callBack = { [weak self] userId in
                    self?.delBlock(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
            
        }
    }
    
    private func delBlacklist(userId: UInt64) {
        web.request(.delBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blacklistViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "黑名单"}) else { return }
                self.blacklistViewModels[index].buttonTitle = "拉黑"
                self.blacklistViewModels[index].buttonStyle = .backgroundColorGray
                self.blacklistViewModels[index].callBack = { [weak self] userId in
                    self?.addBlacklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addBlacklist(userId: UInt64) {
        web.request(.addBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blacklistViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "黑名单"}) else { return }
                self.blacklistViewModels[index].buttonTitle = "恢复"
                self.blacklistViewModels[index].buttonStyle = .borderGray
                self.blacklistViewModels[index].callBack = { [weak self] userId in
                    self?.delBlacklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func invitePhoneContact(phone: String) {
        web.request(.inviteContact(phone: phone)) { (result) in
            switch result {
            case .success:
                guard let index = self.phoneContactViewModels.index(where: { $0.phone == phone }),
                      let section = self.titles.index(where: { $0 == "通讯录"}) else { return }
                self.phoneContactViewModels[index].buttonTitle = "已邀请"
                self.phoneContactViewModels[index].buttonStyle = .noBorderGray
                self.phoneContactViewModels[index].buttonIsEnabled = false
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addSubscription(userId: UInt64) {
        web.request(.addUserSubscription(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.subscriptionsViewModels.index(where: { $0.userId == userId }),
                      let section = self.titles.index(where: { $0 == "我的订阅"}) else { return }
                self.subscriptionsViewModels[index].buttonTitle = "已订阅"
                self.subscriptionsViewModels[index].buttonStyle = .borderBlue
                self.subscriptionsViewModels[index].callBack = { [weak self] userId in
                    self?.delSubscription(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delSubscription(userId: UInt64) {
        web.request(.delUserSubscription(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.subscriptionsViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "我的订阅"}) else { return }
                self.subscriptionsViewModels[index].buttonTitle = "订阅"
                self.subscriptionsViewModels[index].buttonStyle = .backgroundColorBlue
                self.subscriptionsViewModels[index].callBack = { [weak self] userId in
                    self?.addSubscription(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension ContactSearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch titles[section] {
        case "联系人":
            return contactViewModels.count
        case "我的订阅":
            return subscriptionsViewModels.count
        case "通讯录":
            return phoneContactViewModels.count
        case "屏蔽":
            return blockViewModels.count
        case "黑名单":
            return blacklistViewModels.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        switch titles[indexPath.section] {
        case "联系人":
            cell.update(viewModel: contactViewModels[indexPath.row])
        case "我的订阅":
            cell.update(viewModel: subscriptionsViewModels[indexPath.row])
        case "通讯录":
            cell.updatePhoneContact(viewModel: phoneContactViewModels[indexPath.row])
        case "屏蔽":
            cell.update(viewModel: blockViewModels[indexPath.row])
        case "黑名单":
            cell.update(viewModel: blacklistViewModels[indexPath.row])
        default: break
        }
        return cell
    }
}

extension ContactSearchController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
        view?.update(title: titles[section])
        return view
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.searchBar.resignFirstResponder()
        switch titles[indexPath.section] {
        case "联系人":
            showProfile?(contactViewModels[indexPath.row].userId)
        case "我的订阅":
            showProfile?(subscriptionsViewModels[indexPath.row].userId)
        case "通讯录":
            if let userId = phoneContactViewModels[indexPath.row].userId {
                showProfile?(userId)
            }
        case "屏蔽":
            showProfile?(blockViewModels[indexPath.row].userId)
        case "黑名单":
            showProfile?(blacklistViewModels[indexPath.row].userId)
        default: break
        }
    }
}

extension ContactSearchController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        lastestSearchText = searchText
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard self.lastestSearchText == searchText else { return }
            self.searchContact(name: searchText)
        }
    }
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        removeAllData()
        tableView.reloadData()
    }
    func searchBarBookmarkButtonClicked(_ searchBar: UISearchBar) {
        removeAllData()
        tableView.reloadData()
    }
}
