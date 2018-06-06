//
//  ShareCardController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
extension Notification.Name {
    static let dismissShareCard = Notification.Name(rawValue: "dismissShareCard")

}
class ShareCardController: BaseViewController {
    var sendCallback: ((_ content: String, _ userIds: [UInt64]) -> Void)?
    private var userIds = [UInt64]() {
        didSet {
            sendButton.backgroundColor = userIds.count == 0 ? UIColor(hex: 0xf2f2f2) : UIColor.xpBlue()
            sendButton.isEnabled = userIds.count > 0
        }
    }
    private lazy var topView: UIView = {
        let view = UIView()
        return view
    }()
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.frame = CGRect(x: 0, y: 0, width: UIScreen.mainWidth() - 65, height: 25)
        searchBar.setImage(#imageLiteral(resourceName: "SearchSmall"), for: .search, state: .normal)
        searchBar.placeholder = "搜索"
        searchBar.setTextFieldBackgroudColor(color: UIColor.xpGray(), cornerRadius: 3)
        searchBar.barTintColor = .white
        searchBar.backgroundImage = UIImage()
        searchBar.delegate = self
        return searchBar
    }()
    
    private lazy var returnButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("返回", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18)
        button.addTarget(self, action: #selector(returnAction(_:)), for: .touchUpInside)
        return button
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorInset.left = 0
        tableView.tableFooterView = UIView()
        tableView.register(ContactTableViewCell.self, forCellReuseIdentifier: "contactCell")
        tableView.delegate = self
        tableView.dataSource = self
        return tableView
    }()
    
    private lazy var shareTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "分享的话..."
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
        textField.backgroundColor = .white
        textField.addTarget(self, action: #selector(textFieldEditChanged(_:)), for: .editingChanged)
        return textField
    }()
    
    private lazy var sendButton: UIButton = {
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor(hex: 0xf2f2f2)
        button.setTitle("发送", for: .normal)
        button.isEnabled = false
        button.addTarget(self, action: #selector(sendAction(_:)), for: .touchUpInside)
        return button
    }()
    private let keyboard = KeyboardObserver()
    private var sendButtonBottomConstraint: NSLayoutConstraint? 
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        setupTopUI()
        setupBottomUI()
        setupTableViewUI()
        loadContacts()
        keyboard.observe { [weak self] in self?.handleKeyboardEvent($0) }
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(disMissNoti(_:)),
                                               name: .dismissShareCard,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dismissShareCard, object: nil)
    }
    
    @objc private func disMissNoti(_ noti: Notification) {
        dismiss(animated: true, completion: nil)

    }
    @objc private func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    @objc private func sendAction(_ sender: UIButton) {
        sendCallback?(shareTextField.text!, userIds)
    }
    @objc private func textFieldEditChanged(_ textField: UITextField) {
        
    }
    
    private func handleKeyboardEvent(_ event: KeyboardEvent) {
        switch event.type {
        case .willShow, .willHide, .willChangeFrame:
            let keyboardHeight = UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y
            sendButtonBottomConstraint?.constant = -keyboardHeight
            UIView.animate(
                withDuration: event.duration,
                delay: 0,
                options: UIViewAnimationOptions(rawValue: UInt(event.curve.rawValue)),
                animations: {
                    self.view.layoutIfNeeded()
            }, completion: nil)
        default:
            break
        }

    }
    private func setupTableViewUI() {
        view.addSubview(tableView)
        tableView.align(.left)
        tableView.align(.right)
        tableView.pin(.bottom, to: topView)
        tableView.pin(.top, to: shareTextField)

    }
    
    private func setupTopUI() {
        view.addSubview(topView)
        topView.align(.left)
        topView.align(.right)
        topView.align(.top, inset: UIScreen.isIphoneX() ? 44 : 20)
        topView.constrain(height: 50)
        topView.addSubview(returnButton)
        returnButton.constrain(width: 40, height: 25)
        returnButton.centerY(to: topView)
        returnButton.align(.right, inset: 10)
        topView.addSubview(searchBar)
        searchBar.align(.left)
        searchBar.centerY(to: topView)
        searchBar.pin(.left, to: returnButton, spacing: 10)
    }
    
    private func setupBottomUI() {
        view.addSubview(sendButton)
        sendButton.align(.left)
        sendButton.align(.right)
        sendButtonBottomConstraint = sendButton.align(.bottom)
        sendButton.constrain(height: 50)
        view.addSubview(shareTextField)
        shareTextField.align(.left, inset: 10)
        shareTextField.align(.right)
        shareTextField.pin(.top, to: sendButton)
        shareTextField.constrain(height: 50)
    }
    private var contactViewModels = [ContactViewModel]()

    private func loadContacts() {
        web.request(.contactAllList, responseType: Response<ContactListResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.contactViewModels.removeAll()
                response.list.forEach({ (contact) in
                    var viewModel = ContactViewModel(model: contact)
                    viewModel.isHiddeenSelectButton = false
                    self.contactViewModels.append(viewModel)
                })
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }
    
    private func searchContacts(name: String) {
        web.request(.searchContact(name: name), responseType: Response<SearchContactResponse>.self) { (result) in
            switch result {
            case let .success(response):
                self.contactViewModels.removeAll()
                response.contacts.forEach({ (contact) in
                    var viewModel = ContactViewModel(model: contact)
                    viewModel.isHiddeenSelectButton = false
                    self.contactViewModels.append(viewModel)
                })
                self.tableView.reloadData()
            case let .failure(error):
                logger.error(error)
            }
        }
    }

}

extension ShareCardController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText == "" {
            loadContacts()
        } else {
            searchContacts(name: searchText)
        }
    }
}

extension ShareCardController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contactViewModels.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(
            withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else {fatalError()}
        cell.update(viewModel: contactViewModels[indexPath.row])
        return cell
    }
}

extension ShareCardController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? ContactTableViewCell else { fatalError() }
        cell.selectButton.isSelected = !cell.selectButton.isSelected
        if cell.selectButton.isSelected {
            userIds.append(contactViewModels[indexPath.row].userId)
        } else {
            if let index = userIds.index(where: {$0 == contactViewModels[indexPath.row].userId}) {
                userIds.remove(at: index)
            }
        }
    }
}
