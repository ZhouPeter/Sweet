//
//  ContactsController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/5/4.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
let contactsButtonWidth: CGFloat = 44

let contactsButtonHeight: CGFloat = 60

let buttonSpace: CGFloat = 50

protocol IMContactsView: BaseView {
    var showInvite: (() -> Void)? {  get set }
    var showBlack: (() -> Void)? { get set }
    var showProfile: ((UInt64) -> Void)? {  get set }
    var showBlock: (() -> Void)? { get set }
    var showSubscription: (() -> Void)? { get set }
    var showSearch: (() -> Void)? { get set }
}

class IMContactsController: BaseViewController, IMContactsView {
    
    var showSubscription: (() -> Void)?
    var showBlock: (() -> Void)?
    var showInvite: (() -> Void)?
    var showBlack: (() -> Void)?
    var showProfile: ((UInt64) -> Void)?
    var showSearch: (() -> Void)?
    var between72hViewModels = [ContactViewModel]()
    var allViewModels = [ContactViewModel]()
    var viewModelsGroup = [[ContactViewModel]]()
    var titles = [String]()
    private lazy var topBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        return view
    }()
    private var subscribeButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Subscribe"), for: .normal)
        button.setTitle("我的订阅", for: .normal)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.addTarget(self, action: #selector(showSubscription(_:)), for: .touchUpInside)
        return button
    }()
    
    private var inviteButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "AddFriend"), for: .normal)
        button.setTitle("邀请好友", for: .normal)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.addTarget(self, action: #selector(showInvite(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var blockButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Block"), for: .normal)
        button.setTitle("屏蔽来源", for: .normal)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.addTarget(self, action: #selector(showBlock(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var blacklistButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Blacklist"), for: .normal)
        button.setTitle("黑名单", for: .normal)
        button.setTitleColor(UIColor.xpTextGray(), for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 10)
        button.addTarget(self, action: #selector(showBlack(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableViewFooterView: ContactsFooterView = {
        let view = ContactsFooterView(frame: CGRect(x: 0, y: 0, width: UIScreen.mainWidth(), height: 45))
        return view
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactsCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.tableFooterView = tableViewFooterView
        return tableView
    }()
    
    private lazy var searchButton: UIButton = {
        let button = UIButton()
        button.setImage(#imageLiteral(resourceName: "Search"), for: .normal)
        button.addTarget(self, action: #selector(showSearch(_:)), for: .touchUpInside)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.xpGray()
        setupTopUI()
        view.addSubview(tableView)
        tableView.align(.left, to: view)
        tableView.align(.right, to: view)
        tableView.align(.bottom, to: view, inset: UIScreen.safeBottomMargin())
        tableView.pin(to: topBackgroundView, edge: .bottom)
        loadContactAllList()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        parent?.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: searchButton)

    }
    
}

// MARK: - Actions
extension IMContactsController {
    @objc private func showInvite(_ sender: UIButton) {
        self.showInvite?()
    }
    @objc private func showBlack(_ sender: UIButton) {
        self.showBlack?()
    }
    @objc private func showBlock(_ sender: UIButton) {
        self.showBlock?()
    }
    @objc private func showSubscription(_ sender: UIButton) {
        self.showSubscription?()
    }
    @objc private func showSearch(_ sender: UIButton) {
        self.showSearch?()
    }
}

extension IMContactsController {
    private func setupTopUI() {
        view.addSubview(topBackgroundView)
        topBackgroundView.align(.left, to: view)
        topBackgroundView.align(.right, to: view)
        topBackgroundView.align(.top, to: view, inset: UIScreen.navBarHeight() + 2)
        topBackgroundView.constrain(height: 80)
        
        topBackgroundView.addSubview(subscribeButton)
        subscribeButton.constrain(width: contactsButtonWidth, height: contactsButtonHeight)
        subscribeButton.centerY(to: topBackgroundView)
        subscribeButton.centerX(to: topBackgroundView, offset: -(contactsButtonWidth + buttonSpace) / 2)
        subscribeButton.setImageTop(space: 2)
        
        topBackgroundView.addSubview(inviteButton)
        inviteButton.constrain(width: contactsButtonWidth, height: contactsButtonHeight)
        inviteButton.centerY(to: topBackgroundView)
        inviteButton.centerX(to: subscribeButton, offset: -(contactsButtonWidth + buttonSpace))
        inviteButton.setImageTop(space: 2)
        
        topBackgroundView.addSubview(blockButton)
        blockButton.constrain(width: contactsButtonWidth, height: contactsButtonHeight)
        blockButton.centerY(to: topBackgroundView)
        blockButton.centerX(to: topBackgroundView, offset: (contactsButtonWidth + buttonSpace) / 2)
        blockButton.setImageTop(space: 2)
        
        topBackgroundView.addSubview(blacklistButton)
        blacklistButton.constrain(width: contactsButtonWidth, height: contactsButtonHeight)
        blacklistButton.centerY(to: topBackgroundView)
        blacklistButton.centerX(to: blockButton, offset: contactsButtonWidth + buttonSpace)
        blacklistButton.setImageTop(space: 2)
    }
    
    private func loadContactAllList() {
        web.request(.contactAllList, responseType: Response<ContactListResponse>.self) {[weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .success(response):
                let models = response.list
                models.forEach({ (model) in
                    let viewModel = ContactViewModel(model: model)
                    self.allViewModels.append(viewModel)
                    if model.lastTime > Int(Date().timeIntervalSince1970 * 1000 - 3600 * 72) {
                        self.between72hViewModels.append(viewModel)
                    }
                })
                self.between72hViewModels.sort {
                     return $0.lastTime > $1.lastTime
                }
                if self.between72hViewModels.count > 0 {
                    self.viewModelsGroup.append(self.between72hViewModels)
                    self.titles.append("最近联系")
                }
                if self.allViewModels.count > 0 {
                    self.viewModelsGroup.append(self.allViewModels)
                    self.titles.append("全部")
                }
                self.tableViewFooterView.update(title: "\(self.allViewModels.count)位联系人")
                self.tableView.reloadData()

            case let .failure(error):
                logger.error(error)
            }
        }
    }
}

extension IMContactsController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
        view?.update(title: titles[section])
        return view
    }
 
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 25
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showProfile?(viewModelsGroup[indexPath.section][indexPath.row].userId)
    }
    
}

extension IMContactsController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModelsGroup.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModelsGroup[section].count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "contactsCell", for: indexPath) as? ContactTableViewCell else { fatalError() }
        cell.update(viewModel: viewModelsGroup[indexPath.section][indexPath.row])
        return cell
        
    }
}
