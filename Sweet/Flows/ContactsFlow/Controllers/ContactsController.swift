//
//  ContactsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import TencentOpenAPI
private let contactsButtonWidth: CGFloat = 44
private let contactsButtonHeight: CGFloat = 60
private let buttonSpace: CGFloat = 50

class ContactsController: BaseViewController, ContactsView {
    weak var delegate: ContactsViewDelegate?
    private var blacklistViewModel = [ContactViewModel]()
    private var allViewModels = [ContactViewModel]()
    private var titles = ["邀请好友"] {
        didSet {
            if titles.count == 0 {
                titles.append("邀请好友")
            } else if titles[0] != "邀请好友" {
                titles.insert("邀请好友", at: 0)
            }
        }
    }
    private lazy var emptyView: EmptyEmojiView = {
        let view = EmptyEmojiView(image: nil, title: "聊过天的人会出现在这里")
        view.emojiImageView.image = nil
        view.titleLabel.font = UIFont.systemFont(ofSize: 14)
        view.titleLabel.textColor = UIColor.black.withAlphaComponent(0.5)
        return view
    }()
    
    private lazy var categoryViewModels: [ContactCategoryViewModel] = {
        var viewModels = [ContactCategoryViewModel]()
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
        tableView.register(ShareListTableViewCell.self, forCellReuseIdentifier: "shareListCell")
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
            let searchBarHeight = searchController.searchBar.frame.height
            emptyView.frame = CGRect(
                x: 0,
                y: 68 + 25 + 80 + searchBarHeight,
                width: tableView.bounds.width,
                height: tableView.bounds.height - (68 + 25 + 80 + searchBarHeight) + 1
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
        if indexPath.section == 1 {
            return 80
        }
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
                delegate?.contactsShowSubscription()
            }
        } else if indexPath.section == 1 {
            
        } else {
            let viewModel = viewModelsGroup[indexPath.section - 2][indexPath.row]
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
        return viewModelsGroup.count + 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section <= 1 ? 1 : viewModelsGroup[section - 2].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
            cell.updateCategroy(viewModel: categoryViewModels[indexPath.row])
            cell.accessoryType = .disclosureIndicator
            return cell
        } else if indexPath.section == 1 {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "shareListCell", for: indexPath) as? ShareListTableViewCell else { fatalError() }
            cell.update(images: [#imageLiteral(resourceName: "通讯录"), #imageLiteral(resourceName: "微信"), #imageLiteral(resourceName: "朋友圈"), #imageLiteral(resourceName: "QQ"), #imageLiteral(resourceName: "微博")])
            cell.delegate = self
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
            cell.update(viewModel: viewModelsGroup[indexPath.section - 2][indexPath.row])
            cell.accessoryType = .none
            return cell
        }
    }
}


extension ContactsController: ShareListTableViewCellDelegate {
    func didSelectItemAt(index: Int) {
        if index == 0 {
            delegate?.contactsShowInvite()
        } else if index == 1 {
            ShareInviteHelper.sendWXInviteMessage(scene: .conversation)
        } else if index == 2 {
            ShareInviteHelper.sendWXInviteMessage(scene: .timeline)
        } else if index == 3 {
            ShareInviteHelper.sendQQInviteMessage()
        } else if index == 4  {
            ShareInviteHelper.sendWeiboInviteMessage()
        }
    }
}
