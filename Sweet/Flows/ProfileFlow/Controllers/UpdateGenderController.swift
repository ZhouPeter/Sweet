//
//  UpdateGenderController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/28.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateGenderController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String) -> Void)?
    
    var gender: Gender
    private var genders: [Gender] = [.male, .female]
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.register(UpdateGenderTableViewCell.self, forCellReuseIdentifier: "updateGenderCell")
        return tableView
    }()
    
    init(gender: Gender) {
        self.gender = gender
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "选择性别"
        view.addSubview(tableView)
        tableView.fill(in: view, top: 10)
    }

}

extension UpdateGenderController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "updateGenderCell",
            for: indexPath) as? UpdateGenderTableViewCell else { fatalError() }
        cell.update(text: genders[indexPath.row] == .male ? "男" : "女",
                    isSelected: genders[indexPath.row] == gender)
        return cell
    }
}

extension UpdateGenderController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 56
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        web.request(.update(
            updateParameters: ["gender": genders[indexPath.row].rawValue,
                               "type": UpdateUserType.gender.rawValue])) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case .success:
                self.gender = self.genders[indexPath.row]
                for cell in tableView.visibleCells {
                    if let cell = cell as? UpdateGenderTableViewCell, let indexPath = tableView.indexPath(for: cell) {
                        cell.update(text: self.genders[indexPath.row] == .male ? "男" : "女",
                                    isSelected: self.genders[indexPath.row] == self.gender)
                    }
                }
                self.saveCompletion?(self.gender == .male ? "男" : "女")
                self.navigationController?.popViewController(animated: true)
            case let .failure(error):
                logger.error(error)
            }
        }
      
    }
}
