//
//  BlackController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol BlackView: BaseView {
    var showProfile: ((UInt64) -> Void)? { get set }
}
class BlackController: BaseViewController, BlackView {
    var showProfile: ((UInt64) -> Void)?
    
    var viewModels = [ContactViewModel]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.xpGray()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "blackCell")
        tableView.contentInset.top = 10
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "黑名单"
        view.addSubview(tableView)
        tableView.fill(in: view)
        loadBlackContactList()
    }
    
    private func loadBlackContactList() {
        web.request(.blackContactList, responseType: Response<ContactListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                response.list.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlacklist(userId: userId)
                    }
                    self.viewModels.append(viewModel)
                })
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addBlacklist(userId: UInt64) {
        web.request(.addBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.viewModels.index(where: { $0.userId == userId }) else { return }
                self.viewModels[index].buttonStyle = .borderGray
                self.viewModels[index].buttonTitle = "恢复"
                self.viewModels[index].callBack = { [weak self] userId in
                    self?.delBlacklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delBlacklist(userId: UInt64) {
        web.request(.delBlacklist(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.viewModels.index(where: { $0.userId == userId }) else { return }
                self.viewModels[index].buttonStyle = .backgroundColorGray
                self.viewModels[index].buttonTitle = "拉黑"
                self.viewModels[index].callBack = { [weak self] userId in
                    self?.addBlacklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }

}

extension BlackController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "blackCell",
            for: indexPath) as? ContactTableViewCell else { fatalError() }
        cell.update(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension BlackController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProfile?(viewModels[indexPath.row].userId)
    }
    
}
