//
//  EstimatesController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class EvaluationController: UIViewController, PageChildrenProtocol {

    var userId: UInt64
    
    init(userId: UInt64) {
        self.userId = userId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var evalations = [EvaluationResponse]()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(EvaluationTableViewCell.self, forCellReuseIdentifier: "EvaluationCell")
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.fill(in: view)
        
    }
    
    func loadRequest() {
        web.request(
            .evaluationList(page: 0, userId: userId),
            responseType: Response<EvaluationListResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.evalations = response.list
                    self.tableView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
            
        }
    }

}

extension EvaluationController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "EvaluationCell", for: indexPath)as? EvaluationTableViewCell else { fatalError() }
        cell.update(model: evalations[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return evalations.count
    }
}

extension EvaluationController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
}
