//
//  FeedsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class ActivitiesController: UIViewController, PageChildrenProtocol {

    var userId: UInt64
    init(userId: UInt64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    private var activities = [ActivityResponse]()
    private var viewModels = [ActivityViewModel]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(ActivityTableViewCell.self, forCellReuseIdentifier: "ActivityCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    
    func loadRequest() {
        web.request(
          .activityList(page: 0, userId: userId),
          responseType: Response<ActivityListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.activities = response.list
                self.viewModels = response.list.map { return ActivityViewModel(model: $0) }
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension ActivitiesController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "ActivityCell", for: indexPath) as? ActivityTableViewCell else {fatalError()}
        cell.update(viewModels[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return activities.count
    }
}

extension ActivitiesController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return (cardCellHeight - 50) / 4
    }
}
