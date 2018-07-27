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
    private var blacklistViewModel = [ContactViewModel]()
    private var allViewModels = [ContactViewModel]()
    private var titles = [String]()
    private var emptyView = EmptyEmojiView()
    
    private lazy var categoryViewModels: [ContactCategoryViewModel] = {
        var viewModels = [ContactCategoryViewModel]()
        let addViewModel = ContactCategoryViewModel(categoryImage: #imageLiteral(resourceName: "AddFriend"), title: "邀请好友")
        viewModels.append(addViewModel)
        let subViewModel = ContactCategoryViewModel(categoryImage: #imageLiteral(resourceName: "Subscribe"), title: "订阅")
        viewModels.append(subViewModel)
        return viewModels
    } ()
    
    private var viewModelsGroup = [[ContactViewModel]]() {
        didSet { showEmptyView(isShow: viewModelsGroup.count == 0) }
    }

    private lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.separatorInset.left = 60
        tableView.delegate = self
        tableView.dataSource = self
        tableView.sectionFooterHeight = 0
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.tableHeaderView = searchController.searchBar
        tableView.backgroundColor = UIColor(hex: 0xf7f7f7)
        tableView.separatorColor = UIColor(hex: 0xF2F2F2)
        return tableView
    } ()
    private lazy var searchController: UISearchController = {
        let resultController = ContactSearchController()
        let searchController = UISearchController(searchResultsController: resultController)
        searchController.searchResultsUpdater = resultController
        searchController.searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchController.searchBar.placeholder = "搜索人名、手机号"
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.setCancelText(text: "返回", textColor: .black)
        searchController.searchBar.setTextFieldBackgroudColor(color: UIColor.xpGray(), cornerRadius: 3)
        searchController.searchBar.setBorderColor(borderColor: UIColor(hex: 0xF2F2F2))
        searchController.searchBar.backgroundColor = .white
        searchController.searchBar.delegate = self
        searchController.delegate = self
        return searchController
    }()
    // MARK: - Private
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xf7f7f7)
        view.addSubview(tableView)
        tableView.fill(in: view, bottom: UIScreen.safeBottomMargin())
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadContacts()
    }
    
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            tableView.addSubview(emptyView)
            emptyView.backgroundColor = .clear
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
        blacklistViewModel.removeAll()
        viewModelsGroup.removeAll()
        titles.removeAll()
    }
    
    private func loadContacts() {
        web.request(.contactAllList, responseType: Response<ContactListResponse>.self) {[weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                self.removeData()
                let models = response.list
                models.forEach({ (model) in
                    let viewModel = ContactViewModel(model: model)
                    self.allViewModels.append(viewModel)
                })
                let blacklistModels = response.blacklist
                blacklistModels.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model)
                    viewModel.callBack = { [weak self] userId in
                        web.request(.delBlacklist(userId: UInt64(userId)!), completion: { (result) in
                            switch result {
                            case let .failure(error):
                                logger.error(error)
                            case .success:
                                self?.delBlacklist(userId: UInt64(userId)!)
                            }
                        })
                    }
                    self.blacklistViewModel.append(viewModel)
                })
                if self.allViewModels.count > 0 {
                    self.viewModelsGroup.append(self.allViewModels)
                    self.titles.append("联系人")
                }
                if self.blacklistViewModel.count > 0 {
                    self.viewModelsGroup.append(self.blacklistViewModel)
                    self.titles.append("黑名单")
                }
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
                self.loadContacts()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension ContactsController: UISearchControllerDelegate {
    func willPresentSearchController(_ searchController: UISearchController) {
        searchController.searchBar.sizeToFit()
    }
}
extension ContactsController: UISearchBarDelegate {
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        if let searchView = searchController.searchResultsController as? ContactSearchView {
            delegate?.contactsShowSearch(searchView: searchView)
        }
        return true
    }
}

extension ContactsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if section == 0 { return nil }
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
        view?.update(title: section == 0 ? "" : titles[section - 1])
        return view
    }
    
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        if let header = view as? UITableViewHeaderFooterView {
            header.backgroundView?.backgroundColor = .clear
        }
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return CGFloat.leastNormalMagnitude
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
            let viewModel = viewModelsGroup[indexPath.section - 1][indexPath.row]
            let userID = viewModel.userId
            if titles[indexPath.section - 1] == "黑名单" {
                let alertSheet = UIAlertController()
                alertSheet.addAction(UIAlertAction.makeAlertAction(title: "移出黑名单",
                                                                   style: .default,
                                                                   handler: { (_) in
                    self.delBlacklist(userId: userID)
                }))
                alertSheet.addAction(UIAlertAction.makeAlertAction(title: "取消", style: .cancel, handler: nil))
                self.present(alertSheet, animated: true, completion: nil)
            } else {
                delegate?.contactsShowProfile(userID: userID)
            }
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
            withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        if indexPath.section == 0 {
            cell.updateCategroy(viewModel: categoryViewModels[indexPath.row])
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.update(viewModel: viewModelsGroup[indexPath.section - 1][indexPath.row])
            cell.accessoryType = .none
        }
        return cell
    }
}
