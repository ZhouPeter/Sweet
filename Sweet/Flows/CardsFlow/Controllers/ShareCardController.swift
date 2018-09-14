//
//  ShareCardController.swift
//  Sweet
//
//  Created by 周鹏杰 on 2018/6/5.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import SwiftyUserDefaults
import JDStatusBarNotification
import TencentOpenAPI
extension Notification.Name {
    static let dismissShareCard = Notification.Name(rawValue: "dismissShareCard")

}
enum ShareSection {
    case wechat(length: Int)
    case story(length: Int)
    case contact(length: Int)
}

extension ShareCardController: WXApiManagerDelegate {
    func managerDidRecvMessageResponse(response: SendMessageToWXResp) {
        JDStatusBarNotification.show(withStatus: "转发成功", dismissAfter: 2)
    }
}
class ShareCardController: BaseViewController {
    var sendCallback: ((_ content: String, _ userIds: [UInt64]) -> Void)?
    var shareMessageCallback: ((Int) -> Void)?
    var shareStoryCallback: ((_ draft: StoryDraft) -> Void)?
    private var userIds = [UInt64]() {
        didSet {
            sendButton.backgroundColor = (isShareToStory || userIds.count > 0) ?  UIColor.xpBlue() : UIColor(hex: 0xf2f2f2)
            sendButton.isEnabled = (isShareToStory || userIds.count > 0)
        }
    }
    
    private var isShareToStory = false {
        didSet {
            sendButton.backgroundColor = (isShareToStory || userIds.count > 0) ? UIColor.xpBlue() : UIColor(hex: 0xf2f2f2)
            sendButton.isEnabled = (isShareToStory || userIds.count > 0)
        }
    }

    private lazy var topView = UIView()
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
        tableView.register(ModuleTableViewCell.self, forCellReuseIdentifier: "moduleCell")
        tableView.register(ShareListTableViewCell.self, forCellReuseIdentifier: "shareListCell")
        tableView.register(SweetHeaderView.self, forHeaderFooterViewReuseIdentifier: "headerView")
        tableView.delegate = self
        tableView.dataSource = self
        tableView.estimatedSectionHeaderHeight = 0
        return tableView
    }()
    private lazy var segmentLineView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.xpSeparatorGray()
        return view
    }()
    private lazy var shareTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "转发的话..."
        textField.font = UIFont.systemFont(ofSize: 14)
        textField.textColor = .black
        textField.backgroundColor = .white
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
    private var shareText: String?
    private var storyDraft: StoryDraft?
    private var sections = [ShareSection]()
    init() {
        super.init(nibName: nil, bundle: nil)
    }
    init(shareText: String?) {
        self.shareText = shareText
        super.init(nibName: nil, bundle: nil)
    }
    
    init(shareText: String?, storyDraft: StoryDraft?) {
        self.shareText = shareText
        self.storyDraft = storyDraft
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
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
        WXApiManager.shared.delegate = self
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .dismissShareCard, object: nil)
        WXApiManager.shared.delegate = nil
    }
    
    @objc private func disMissNoti(_ noti: Notification) {
        dismiss(animated: true, completion: nil)

    }
    @objc private func returnAction(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    private var storyPublishToken: NSKeyValueObservation?
    @objc private func sendAction(_ sender: UIButton) {
        sendCallback?(shareTextField.text!, userIds)
        if var draft = storyDraft, isShareToStory {
            draft.comment = shareTextField.text
            shareStoryCallback?(draft)
        }
    }
    
    private func updateSections() {
        sections.removeAll()
        if shareText != nil {
            sections.append(.wechat(length: 1))
        }
        if storyDraft != nil {
            sections.append(.story(length: 1))
        }
        if contactViewModels.count > 0 {
            sections.append(.contact(length: contactViewModels.count))
        }
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
        tableView.pin(.top, to: segmentLineView)

    }
    
    private func setupTopUI() {
        view.addSubview(topView)
        topView.align(.left)
        topView.align(.right)
        topView.align(.top, inset: UIScreen.isNotched() ? 44 : 20)
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
        view.addSubview(segmentLineView)
        segmentLineView.align(.left)
        segmentLineView.align(.right)
        segmentLineView.constrain(height: 0.5)
        segmentLineView.pin(.top, to: shareTextField)
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
                self.updateSections()
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
                self.updateSections()
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
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .wechat(let length), .story(let length), .contact(let length):
            return length
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .wechat:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "shareListCell", for: indexPath) as? ShareListTableViewCell else {fatalError()}
            cell.update(images: [ #imageLiteral(resourceName: "微信"), #imageLiteral(resourceName: "朋友圈"), #imageLiteral(resourceName: "QQ")])
            cell.delegate = self
            return cell
        case .story:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "moduleCell", for: indexPath) as? ModuleTableViewCell else {fatalError()}
            cell.update(image: #imageLiteral(resourceName: "StoryCover"), text: "转发到小故事", isCanSelected: true)
            cell.addDateOnImage()
            return cell
        case .contact:
            guard let cell = tableView.dequeueReusableCell(
                withIdentifier: "contactCell", for: indexPath) as? ContactTableViewCell else {fatalError()}
            cell.update(viewModel: contactViewModels[indexPath.row])
            return cell
        }
    }
}

extension ShareCardController: ShareListTableViewCellDelegate {
    func didSelectItemAt(index: Int) {
        if index == 0 {
            WXApi.sendText(text: shareText!, scene: .conversation, isCallLog: false)
            shareMessageCallback?(0)
        } else if index == 1 {
            WXApi.sendText(text: shareText!, scene: .timeline, isCallLog: false)
            shareMessageCallback?(1)
        } else if index == 2 {
            QQApiInterface.sendText(text: shareText!, isCallLog: false)
            shareMessageCallback?(3)
        }
    }
    
}

extension ShareCardController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .story, .contact:
            return 8
        case .wechat:
            return 25
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch sections[section] {
        case .wechat:
            let header = tableView.dequeueReusableHeaderFooterView(withIdentifier: "headerView") as? SweetHeaderView
            header?.update(title: "转发到")
            return header
        default:
            return nil
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .wechat:
            return 80
        default:
            return 68
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .wechat: break
        case .story:
            guard let cell = tableView.cellForRow(at: indexPath) as? ModuleTableViewCell else { fatalError() }
            cell.selectButton.isSelected = !cell.selectButton.isSelected
            isShareToStory = cell.selectButton.isSelected
        case .contact:
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
}
