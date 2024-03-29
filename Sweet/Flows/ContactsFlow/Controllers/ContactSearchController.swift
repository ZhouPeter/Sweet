//
//  ContactSearchController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/9.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol ContactSearchView: BaseView {
    var showProfile: ((UInt64) -> Void)? { get set }
}

class ContactSearchController: BaseViewController, ContactSearchView {
    var showProfile: ((UInt64) -> Void)?
    var contactViewModels = [ContactViewModel]()
    var blacklistViewModels = [ContactViewModel]()
    var userViewModels = [ContactViewModel]()
    var phoneContactViewModels = [PhoneContactViewModel]()
    var titles = [String]()
    private var lastestSearchText: String = ""
    private lazy var backButton: UIButton = {
        let button = UIButton()
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 25)
        button.setTitleColor(.black, for: .normal)
        button.setTitle("返回", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(backAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth() - 65, height: 44)
        searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchBar.placeholder = "搜索人名、手机号"
        searchBar.setCancelText(text: "返回", textColor: .black)
        searchBar.setTextFieldBackgroudColor(color: UIColor.xpGray(), cornerRadius: 3)
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
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        searchBar.becomeFirstResponder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        searchBar.resignFirstResponder()
    }
    
    @objc private func backAction(_ sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    private func removeAllData() {
        contactViewModels.removeAll()
        phoneContactViewModels.removeAll()
        blacklistViewModels.removeAll()
        userViewModels.removeAll()
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
                response.blacklists.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlacklist(userId: UInt64(userId)!)
                    }
                    self.blacklistViewModels.append(viewModel)
                })
               
                response.phoneContacts.forEach({ (model) in
                    var viewModel = PhoneContactViewModel(model: model)
                    viewModel.callBack = { [weak self] phone in
                        self?.invitePhoneContact(phone: String(phone))
                    }
                    self.phoneContactViewModels.append(viewModel)
                })
                response.users.forEach({ (model) in
                    let viewModel = ContactViewModel(model: model)
                    self.userViewModels.append(viewModel)
                })
                if self.contactViewModels.count == 0 &&
                    self.blacklistViewModels.count == 0 &&
                    self.phoneContactViewModels.count == 0 &&
                    self.userViewModels.count == 0 && name.checkPhone() {
                    let model = PhoneContact(name: name,
                                             phone: name,
                                             status: .notInvited,
                                             registerStatus: .unRegister,
                                             avatar: nil,
                                             info: nil,
                                             nickname: nil,
                                             userId: nil)
                    var viewModel = PhoneContactViewModel(model: model)
                    viewModel.callBack = { [weak self] phone in
                        self?.invitePhoneContact(phone: String(phone))
                    }
                    viewModel.placeholderAvatar = #imageLiteral(resourceName: "Emoji1")
                    self.phoneContactViewModels.append(viewModel)
                }
            
                if self.contactViewModels.count > 0 { self.titles.append("联系人") }
                if self.blacklistViewModels.count > 0 { self.titles.append("黑名单") }
                if self.phoneContactViewModels.count > 0 { self.titles.append("通讯录") }
                if self.userViewModels.count > 0 { self.titles.append("用户") }
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
                guard let index = self.blacklistViewModels.index(where: { $0.userId == userId }),
                    let section = self.titles.index(where: { $0 == "黑名单"}) else { return }
                self.blacklistViewModels[index].buttonTitle = "拉黑"
                self.blacklistViewModels[index].buttonStyle = .backgroundColorGray
                self.blacklistViewModels[index].callBack = { [weak self] userId in
                    self?.addBlacklist(userId: UInt64(userId)!)
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
                    self?.delBlacklist(userId: UInt64(userId)!)
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
    
}

extension ContactSearchController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch titles[section] {
        case "联系人":
            return contactViewModels.count
        case "黑名单":
            return blacklistViewModels.count
        case "通讯录":
            return phoneContactViewModels.count
        case "用户":
            return userViewModels.count
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
        case "黑名单":
            cell.update(viewModel: blacklistViewModels[indexPath.row])
        case "通讯录":
            cell.updatePhoneContact(viewModel: phoneContactViewModels[indexPath.row])
        case "用户":
            cell.update(viewModel: userViewModels[indexPath.row])
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
        case "黑名单":
            showProfile?(blacklistViewModels[indexPath.row].userId)
        case "通讯录":
            if let userId = phoneContactViewModels[indexPath.row].userId {
                showProfile?(userId)
            }
        case "用户":
            showProfile?(userViewModels[indexPath.row].userId)
        default: break
        }
    }
}
extension ContactSearchController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        lastestSearchText = searchController.searchBar.text!
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            guard self.lastestSearchText == searchController.searchBar.text! else { return }
            self.searchContact(name: searchController.searchBar.text!)
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
