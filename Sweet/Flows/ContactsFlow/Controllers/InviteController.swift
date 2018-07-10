//
//  InviteController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
protocol InviteView: BaseView {
    var delegate: InviteViewDelegate? { get set }
}

protocol InviteViewDelegate: class {
    func showProfile(userId: UInt64)
}
class InviteController: BaseViewController, InviteView {
    weak var delegate: InviteViewDelegate?
    private var viewModels = [PhoneContactViewModel]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "inviteCell")
        tableView.register(ModuleTableViewCell.self, forCellReuseIdentifier: "moduleCell")
        tableView.keyboardDismissMode = .onDrag
        tableView.tableHeaderView = searchController.searchBar
        return tableView
    }()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchBar.placeholder = "搜索人名、手机号"
        searchBar.delegate = self
        searchBar.barTintColor = .white
        searchBar.isTranslucent = true
        return searchBar
    }()
    private lazy var searchController: UISearchController = {
        let resultController = ContactSearchController()
        let searchController = UISearchController(searchResultsController: resultController)
        searchController.searchResultsUpdater = resultController
        searchController.searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchController.searchBar.placeholder = "搜索人名、手机号"
        searchController.searchBar.barTintColor = .white
        searchController.searchBar.setCancelText(text: "返回", textColor: .black)
        searchController.searchBar.setTextFieldBackgroudColor(color: UIColor.xpGray(), cornerRadius: 3)
        return searchController
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "邀请好友"
        view.addSubview(tableView)
        tableView.fill(in: view)
        loadPhoneContactList()
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
    }
    
    private func loadPhoneContactList() {
        web.request(.phoneContactList,
                    responseType: Response<PhoneContactList>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                response.list.forEach({ (model) in
                    var viewModel = PhoneContactViewModel(model: model)
                    viewModel.callBack = { phone in
                        web.request(.inviteContact(phone: String(phone)), completion: { (result) in
                            switch result {
                            case .success:
                                guard let index = self.viewModels.index(
                                                  where: { $0.phone == String(phone) }) else { return }
                                self.viewModels[index].buttonStyle = .noBorderGray
                                self.viewModels[index].buttonTitle = "已邀请"
                                self.viewModels[index].buttonIsEnabled = false
                                if !Defaults[.isInvited] {
                                    let alert = UIAlertController(title: nil, message: "邀请成功", preferredStyle: .alert)
                                    alert.addAction(UIAlertAction(title: "好的", style: .default, handler: nil))
                                    self.present(alert, animated: true, completion: nil)
                                }
                                Defaults[.isInvited] = true
                                self.tableView.reloadRows(at: [IndexPath(row: index, section: 1)], with: .automatic)
                            case let .failure(error):
                                logger.error(error)
                            }
                        })
                    }
                    self.viewModels.append(viewModel)
                })
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension InviteController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModels.count > 0 ? 2 : 1
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return section == 0 ? 1 : viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "moduleCell", for: indexPath)
                as? ModuleTableViewCell else {fatalError()}
            cell.update(image: #imageLiteral(resourceName: "Wechat"), text: "从微信邀请")
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "inviteCell",
                for: indexPath) as? ContactTableViewCell else { fatalError() }
            cell.updatePhoneContact(viewModel: viewModels[indexPath.row])
            return cell
        }
      
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SweetHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainWidth(), height: 25))
        view.update(title: "通讯录")
        return view
    }
    
}

extension InviteController: UISearchBarDelegate {
    
}

extension InviteController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return section == 0 ? 0 : 25
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
            if let url = Defaults[.inviteUrl] {
                let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
                WXApi.sendText(text: text, scene: .conversation)
            } else {
                web.request(.inviteUrl) { (result) in
                    switch result {
                    case let .success(response):
                        if let url = response["url"] as? String {
                            let text = "讲真APP超级好玩，你也下载来和我一起玩吧：\(url)"
                            WXApi.sendText(text: text, scene: .conversation)
                            Defaults[.inviteUrl] = url
                        }
                    case let .failure(error):
                        logger.error(error)
                    }
                }
            }
        } else if indexPath.section == 1 {
            if let userId = viewModels[indexPath.row].userId {
                delegate?.showProfile(userId: userId)
            }
        }
    }
}
