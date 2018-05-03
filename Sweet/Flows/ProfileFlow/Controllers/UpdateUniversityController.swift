//
//  UpdateUniversityController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateUniversityController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String) -> Void)?
    
    var universityName: String
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
    
    init(universityName: String) {
        self.universityName = universityName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改学校"
        setupUI()
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
        searchBar.align(.top, to: view, inset: UIScreen.navBarHeight() + 10)
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

extension UpdateUniversityController: UITableViewDataSource {
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

extension UpdateUniversityController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
         let controller = UpdateCollegeController(universityName: universitys[indexPath.row].universityName)
        controller.saveCompletion = self.saveCompletion
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension UpdateUniversityController: UISearchBarDelegate {
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
