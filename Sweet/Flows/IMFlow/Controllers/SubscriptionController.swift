//
//  SubscriptionController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/8.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

protocol SubscriptionView: BaseView {
    var showProfile: ((UInt64) -> Void)? { get set }
}
class SubscriptionController: BaseViewController, SubscriptionView {
    var showProfile: ((UInt64) -> Void)?
    private var sectionViewModels = [ContactSubcriptionSectionViewModel]()
    private var userViewModels = [ContactViewModel]()
    private var blockViewModels = [ContactViewModel]()
    private var titles = [String]()
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.backgroundColor = UIColor.xpGray()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "subscriptionCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "订阅"
        view.addSubview(tableView)
        tableView.fill(in: view)
        loadSubcriptionList()

    }
    
    private func loadSubcriptionList() {
        web.request(.subscriptionList, responseType: Response<SubscriptionListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                response.sections.forEach({ (model) in
                    var viewModel = ContactSubcriptionSectionViewModel(model: model)
                    viewModel.callBack = { [weak self] sectionId in
                        self?.delSectionSubscription(sectionId: sectionId)
                    }
                    self.sectionViewModels.append(viewModel)
                })
                response.users.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "已订阅", style: .borderBlue)
                    viewModel.callBack = { [weak self] userId in
                        self?.delUserSubscription(userId: userId)
                    }
                    self.userViewModels.append(viewModel)
                })
                response.blocks.forEach({ (model) in
                    var viewModel = ContactViewModel(model: model, title: "恢复", style: .borderGray)
                    viewModel.callBack = { [weak self] userId in
                        self?.delBlocklist(userId: userId)
                    }
                    self.blockViewModels.append(viewModel)
                })
                if self.sectionViewModels.count > 0 { self.titles.append("栏目") }
                if self.userViewModels.count > 0 { self.titles.append("用户") }
                if self.blockViewModels.count > 0 { self.titles.append("屏蔽") }
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
                guard let index = self.blockViewModels.index(where: { $0.userId == userId }) else { return }
                self.blockViewModels[index].buttonStyle = .borderGray
                self.blockViewModels[index].buttonTitle = "恢复"
                self.blockViewModels[index].callBack = { [weak self] userId in
                    self?.delBlocklist(userId: userId)
                }
                let section: Int = self.titles.index(of: "屏蔽")!
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delBlocklist(userId: UInt64) {
        web.request(.delBlock(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.blockViewModels.index(where: { $0.userId == userId }) else { return }
                self.blockViewModels[index].buttonStyle = .backgroundColorGray
                self.blockViewModels[index].buttonTitle = "屏蔽"
                self.blockViewModels[index].callBack = { [weak self] userId in
                    self?.addBlocklist(userId: userId)
                }
                let section: Int = self.titles.index(of: "屏蔽")!
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    private func delUserSubscription(userId: UInt64) {
        web.request(.delUserSubscription(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.userViewModels.index(where: { $0.userId == userId }) else { return }
                self.userViewModels[index].buttonStyle = .backgroundColorBlue
                self.userViewModels[index].buttonTitle = "订阅"
                self.userViewModels[index].callBack = { [weak self] userId in
                    self?.addUserSubscription(userId: userId)
                }
                let section: Int = self.titles.index(of: "用户")!
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addUserSubscription(userId: UInt64) {
        web.request(.addUserSubscription(userId: userId)) { (result) in
            switch result {
            case .success:
                guard let index = self.userViewModels.index(where: { $0.userId == userId }) else { return }
                self.userViewModels[index].buttonStyle = .borderBlue
                self.userViewModels[index].buttonTitle = "已订阅"
                self.userViewModels[index].callBack = { [weak self] userId in
                    self?.delUserSubscription(userId: userId)
                }
                let section: Int = self.titles.index(of: "用户")!
                self.tableView.reloadRows(at: [IndexPath(row: index, section: section)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func delSectionSubscription(sectionId: UInt64) {
        web.request(.delSectionSubscription(sectionId: sectionId)) { (result) in
            switch result {
            case .success:
                guard let index = self.sectionViewModels.index(where: { $0.sectionId == sectionId }) else { return }
                self.sectionViewModels[index].buttonStyle = .backgroundColorBlue
                self.sectionViewModels[index].buttonTitle = "订阅"
                self.sectionViewModels[index].callBack = { [weak self] sectionId in
                    self?.addSectionSubscription(sectionId: sectionId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func addSectionSubscription(sectionId: UInt64) {
        web.request(.addSectionSubscription(sectionId: sectionId)) { (result) in
            switch result {
            case .success:
                guard let index = self.sectionViewModels.index(where: { $0.sectionId == sectionId }) else { return }
                self.sectionViewModels[index].buttonStyle = .borderBlue
                self.sectionViewModels[index].buttonTitle = "已订阅"
                self.sectionViewModels[index].callBack = { [weak self] sectionId in
                    self?.delSectionSubscription(sectionId: sectionId)
                }
                self.tableView.reloadRows(at: [IndexPath(row: index, section: 0)], with: .automatic)
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension SubscriptionController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return titles.count
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if titles[section] == "栏目" {
            return sectionViewModels.count
        } else if titles[section] == "用户" {
            return userViewModels.count
        } else if titles[section] == "屏蔽" {
            return blockViewModels.count
        } else {
            return 0
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "subscriptionCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        if titles[indexPath.section] == "栏目" {
            cell.updateSectionWithButton(viewModel: sectionViewModels[indexPath.row])
        } else if titles[indexPath.section] == "用户"{
            cell.update(viewModel: userViewModels[indexPath.row])
        } else if titles[indexPath.section] == "屏蔽" {
            cell.update(viewModel: blockViewModels[indexPath.row])
        }
        return cell
    }
}

extension SubscriptionController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return  80
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if titles[indexPath.section] == "栏目" {
            
        } else if titles[indexPath.section] == "用户" {
            showProfile?(userViewModels[indexPath.row].userId)
        } else if titles[indexPath.section] == "屏蔽" {
            showProfile?(blockViewModels[indexPath.row].userId)
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(
                        withIdentifier: "headerView") as? SweetHeaderView
        view?.update(title: titles[section])
        return view
    }
}
