//
//  SignUpUniversityController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/4/19.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class SignUpUniversityController: BaseViewController, SignUpUniversityView {
    var showSignUpCollege: ((LoginRequestBody) -> Void)?
    
    var loginRequestBody: LoginRequestBody!
    
    private var universitys = [University]() {
        willSet {
            showEmptyView(isShow: false)
        }
    }
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "搜索学校"
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
    
    private lazy var emptyView: EmptyView = {
        let emptyView = EmptyView()
        emptyView.titleLabel.text = "你搜索的学校不存在"
        return emptyView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.barTintColor = UIColor.xpYellow()
        navigationItem.title = "你的学校"
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = false
    }
    
    private func showEmptyView(isShow: Bool) {
        if isShow {
            if emptyView.superview != nil { return }
            tableView.addSubview(emptyView)
            emptyView.frame = CGRect(x: 0,
                                     y: 0,
                                     width: tableView.bounds.width,
                                     height: tableView.bounds.height + 1)
            
        } else {
            emptyView.removeFromSuperview()
        }
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
    
    private func searchUniversity(universityName: String) {
        guard universityName != "" else {
            universitys.removeAll()
            tableView.reloadData()
            return
        }
        web.request(
            .searchUniversity(name: universityName),
            responseType: Response<SearchUniversityResponse>.self) {(result) in
            switch result {
            case let .failure(error):
                logger.error(error)
            case let.success(response):
                logger.debug(response)
                self.universitys =  response.universityInfos
                self.tableView.reloadData()
            }
        }
    }
}

extension SignUpUniversityController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return universitys.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
            as? ContentTextTableViewCell
            else { fatalError() }
        cell.updateWithText(universitys[indexPath.row].universityName)
        return cell
    }
}

extension SignUpUniversityController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        loginRequestBody.universityName = universitys[indexPath.row].universityName
        showSignUpCollege?(loginRequestBody)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension SignUpUniversityController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        self.showEmptyView(isShow: self.universitys.count == 0)
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUniversity(universityName: searchText)
    }
    
}
