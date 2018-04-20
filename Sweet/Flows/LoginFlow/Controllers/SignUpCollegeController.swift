//
//  SignUpCollegeController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpCollegeController: BaseViewController, SignUpCollegeView {
    var showSignUpEnrollment: ((RegisterModel) -> Void)?
    var registerModel: RegisterModel!
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索学院"
        searchBar.tintColor = UIColor.xpTextGray()
        searchBar.barTintColor = .white
        searchBar.isTranslucent = true
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        tableView.separatorInset.left = 0
        tableView.register(ContentTextTableViewCell.self, forCellReuseIdentifier: "cell")
        tableView.keyboardDismissMode = .onDrag
        return tableView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        navigationItem.title = "你的学院"
        setupUI()

    }
    
    private func setupUI() {
        view.addSubview(searchBar)
        searchBar.align(.top, to: view, inset: UIScreen.navBarHeight())
        searchBar.align(.left, to: view)
        searchBar.align(.right, to: view)
        searchBar.constrain(height: 40)
        view.addSubview(tableView)
        tableView.align(.left, to: view)
        tableView.align(.right, to: view)
        tableView.pin(to: searchBar, edge: .bottom)
        tableView.align(.bottom, to: view, inset: UIScreen.isIphoneX() ? 34 : 0)
    }
}

extension SignUpCollegeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as? ContentTextTableViewCell
            else { fatalError() }
        cell.updateWithText("教育学院")
        return cell
    }
}

extension SignUpCollegeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let collegeName = "杭州师范大学"
        registerModel.collegeName = collegeName
        showSignUpEnrollment?(registerModel)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension SignUpCollegeController: UISearchBarDelegate {
    
}
