//
//  TopicListController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Moya

final class TopicListController: UIViewController, TopicListView {
    var onFinished: ((String?) -> Void)?
    var onCancelled: (() -> Void)?
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.backgroundColor = .clear
        view.dataSource = self
        view.delegate = self
        view.rowHeight = 42
        view.separatorStyle = .none
        view.register(TopicCell.self, forCellReuseIdentifier: "Cell")
        view.register(TopicSearchCell.self, forCellReuseIdentifier: "Search")
        return view
    } ()
    
    private lazy var allButton: UIButton = {
        let allButton = UIButton(type: .custom)
        allButton.setTitle("标签", for: .normal)
        allButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        allButton.setTitleColor(.white, for: .normal)
        allButton.enableShadow()
        return allButton
    } ()
    private let keyboardObserver = KeyboardObserver()
    private weak var addTopicButton: UIButton?
    private weak var searchField: UITextField?
    private var searchRequest: Cancellable?
    private var topics = [String]()
    private var tableViewBottom: NSLayoutConstraint?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.align(.left)
        tableView.align(.right)
        tableView.align(.top)
        tableViewBottom = tableView.align(.bottom)
        let inset: CGFloat = 56
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -inset)
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(#imageLiteral(resourceName: "StoryClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        closeButton.enableShadow()
        view.addSubview(closeButton)
        closeButton.align(.top, to: view, inset: 10)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.constrain(width: 30, height: 30)
        
        view.addSubview(allButton)
        allButton.constrain(width: 50, height: 40)
        allButton.align(.left, to: view, inset: 10)
        
        loadAllTopics()
        
        keyboardObserver.observe { [weak self] (event) in
            self?.tableViewBottom?.constant = -(UIScreen.main.bounds.height - event.keyboardFrameEnd.origin.y)
        }
    }
    
    // MARK: - Private
    
    private func loadAllTopics() {
        web.request(.storyTopics, responseType: Response<TopicListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .failure(error):
                logger.error(error)
            case let .success(response):
                self.topics = response.tags
                self.tableView.reloadSections([1], with: .fade)
            }
        }
    }
    
    private func search(with text: String) {
        searchRequest?.cancel()
        searchRequest = web.request(
            .searchTopic(topic: text),
            responseType: Response<TopicListResponse>.self
        ) { [weak self] (result) in
            guard case .success(let response) = result, let `self` = self else { return }
            self.topics = response.tags
            self.tableView.reloadSections([1], with: .fade)
        }
    }
    
    private func dismiss() {
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
    
    // MARK: - Actions
    
    @objc private func didPressCloseButton() {
        onCancelled?()
        dismiss()
    }
    
    @objc private func searchFieldDidChange(_ textField: UITextField) {
        logger.debug(textField.text ?? "")
        if let text = textField.text {
            let count = text.count
            if count > 0 && count <= 10 {
                addTopicButton?.isEnabled = true
                search(with: text)
                return
            } else if count == 0 {
                loadAllTopics()
            }
        }
        addTopicButton?.isEnabled = false
    }
    
    @objc private func didPressAddButton() {
        onFinished?(searchField?.text)
        dismiss()
    }
}

extension TopicListController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            guard let cell =
                tableView.dequeueReusableCell(withIdentifier: "Search", for: indexPath) as? TopicSearchCell else {
                fatalError()
            }
            addTopicButton = cell.addButton
            cell.addButton.addTarget(self, action: #selector(didPressAddButton), for: .touchUpInside)
            searchField = cell.searchField
            cell.searchField.delegate = self
            cell.searchField.addTarget(self, action: #selector(searchFieldDidChange(_:)), for: .editingChanged)
            return cell
        }
        if let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TopicCell {
            let topic = topics[indexPath.row]
            cell.topic = topic
            return cell
        }
        fatalError()
    }
}

extension TopicListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard indexPath.section > 0 else { return }
        onFinished?(topics[indexPath.row])
        dismiss()
    }
}

extension TopicListController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
