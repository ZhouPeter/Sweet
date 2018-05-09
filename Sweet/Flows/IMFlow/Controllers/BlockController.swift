//
//  BlockController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
protocol BlockView: BaseView {
    var showProfile: ((UInt64) -> Void)? { get set }
}
class BlockController: BaseViewController, BlockView {
    var showProfile: ((UInt64) -> Void)?
    
    private var viewModels = [ContactWithButtonViewModel]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.xpGray()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "blockCell")
        tableView.contentInset.top = 10
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "屏蔽"
        view.addSubview(tableView)
        tableView.fill(in: view)
        loadBlockContactList()
    }
    
    deinit {
         logger.debug("释放")
    }
    
    private func loadBlockContactList() {
        web.request(.blockContactList, responseType: Response<ContactListResponse>.self) {(result) in
            switch result {
            case let .success(response):
                response.list.forEach({ (model) in
                    var viewModel = ContactWithButtonViewModel(model: model)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlocklist(userId: userId)
                    }
                    self.viewModels.append(viewModel)
                })
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }

    private func addBlocklist(userId: UInt64) {
        web.request(.addBlock(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.viewModels.index(where: { $0.userId == userId }) else { return }
                self.viewModels[index].buttonStyle = .borderGray
                self.viewModels[index].buttonTitle = "恢复"
                self.viewModels[index].callBack = { [weak self] userId in
                    self?.delBlocklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delBlocklist(userId: UInt64) {
        web.request(.delBlock(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.viewModels.index(where: { $0.userId == userId }) else { return }
                self.viewModels[index].buttonStyle = .backgroudColorGray
                self.viewModels[index].buttonTitle = "屏蔽"
                self.viewModels[index].callBack = { [weak self] userId in
                    self?.addBlocklist(userId: userId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension BlockController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "blockCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        cell.updateContactWithButton(viewModel: viewModels[indexPath.row])
        return cell
    }
}

extension BlockController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProfile?(viewModels[indexPath.row].userId)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
}
