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
    private var userViewModels = [ContactWithButtonViewModel]()
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
                    let viewModel = ContactSubcriptionSectionViewModel(model: model)
                    self.sectionViewModels.append(viewModel)
                })
                response.users.forEach({ (model) in
                    let viewModel = ContactWithButtonViewModel(model: model, buttonTitle: "已订阅")
                    self.userViewModels.append(viewModel)
                })
                if self.sectionViewModels.count > 0 { self.titles.append("栏目") }
                if self.userViewModels.count > 0 { self.titles.append("用户") }
                self.tableView.reloadData()
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
        } else {
            return userViewModels.count
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "subscriptionCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        if titles[indexPath.section] == "栏目" {
            cell.updateSectionWithButton(viewModel: sectionViewModels[indexPath.row])
        } else {
            cell.updateContactWithButton(viewModel: userViewModels[indexPath.row])
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
            
        } else {
            showProfile?(userViewModels[indexPath.row].userId)
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
