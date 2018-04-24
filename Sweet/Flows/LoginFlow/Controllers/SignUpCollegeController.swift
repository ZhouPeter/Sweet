//
//  SignUpCollegeController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpCollegeController: BaseViewController, SignUpCollegeView {
    var showSignUpEnrollment: ((LoginRequestBody) -> Void)?
    var loginRequestBody: LoginRequestBody!
    private var colleges = [College]()
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
        searchCollege(collegeName: "")

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
    
    private func searchCollege(collegeName: String) {
        web.request(
            .searchCollege(collegeName: collegeName, universityName: loginRequestBody.universityName!),
            responseType: Response<SearchCollegeResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.colleges = response.data.collegeInfos
                    self.tableView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }

    }
}

extension SignUpCollegeController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return colleges.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as? ContentTextTableViewCell
            else { fatalError() }
        cell.updateWithText(colleges[indexPath.row].collegeName)
        return cell
    }
}

extension SignUpCollegeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loginRequestBody.collegeName = colleges[indexPath.row].collegeName
        showSignUpEnrollment?(loginRequestBody)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension SignUpCollegeController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCollege(collegeName: searchText)
    }
}
