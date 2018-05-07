//
//  InviteController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/7.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol InviteView: BaseView {
    
}
class InviteController: BaseViewController, InviteView {
    private var viewModels = [PhoneContactViewModel]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "inviteCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "邀请好友"
        view.addSubview(tableView)
        tableView.fill(in: view)
        loadPhoneContactList()
    }
    
    private func loadPhoneContactList() {
        web.request(.phoneContactList,
                    responseType: Response<PhoneContactList>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                response.list.forEach({ (model) in
                    let viewModel = PhoneContactViewModel(model: model)
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
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       guard let cell = tableView.dequeueReusableCell(
                                withIdentifier: "inviteCell",
                                for: indexPath) as? ContactTableViewCell else { fatalError() }
        cell.updatePhoneContact(viewModel: viewModels[indexPath.row])
        return cell
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = SweetHeaderView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainWidth(), height: 25))
        view.update(title: "通讯录")
        return view
    }
    
}

extension InviteController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
}
