//
//  UpdateCollegeController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/2.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

class UpdateCollegeController: BaseViewController, UpdateProtocol {
    var saveCompletion: ((String) -> Void)?
    
    var universityName: String
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
    
    init(universityName: String) {
        self.universityName = universityName
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "修改学院"
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
            .searchCollege(collegeName: collegeName, universityName: universityName),
            responseType: Response<SearchCollegeResponse>.self) { (result) in
                switch result {
                case let .success(response):
                    self.colleges = response.collegeInfos
                    self.tableView.reloadData()
                case let .failure(error):
                    logger.error(error)
                }
        }
    }
    
    private func popToUpdateController() {
        let viewControllers = navigationController!.viewControllers
        for viewController in viewControllers where viewController is UpdateController {
            navigationController?.popToViewController(viewController, animated: true)
        }
    }
}

extension UpdateCollegeController: UITableViewDataSource {
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

extension UpdateCollegeController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let beforeController = navigationController!.viewControllers[navigationController!.viewControllers.count - 2]
        var parameters: [String: Any] = [:]
        if beforeController is UpdateUniversityController {
            parameters = ["universityName": universityName,
                          "collegeName": colleges[indexPath.row].collegeName,
                          "type": UpdateUserType.university.rawValue]
        } else {
            parameters = ["collegeName": colleges[indexPath.row].collegeName,
                          "type": UpdateUserType.college.rawValue]
        }
        web.request(.update(updateParameters: parameters)) { (result) in
            switch result {
            case .success:
                self.saveCompletion?(self.universityName + "#" + self.colleges[indexPath.row].collegeName)
                self.popToUpdateController()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
}

extension UpdateCollegeController: UISearchBarDelegate {
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchCollege(collegeName: searchText)
    }
}
