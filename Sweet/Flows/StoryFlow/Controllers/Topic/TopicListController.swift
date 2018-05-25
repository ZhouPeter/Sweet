//
//  TopicListController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

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
    
    private var allSelectedIndexPath: IndexPath?
    private var topics = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.fill(in: view)
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
    }
    
    // MARK: - Private
    
    private func loadAllTopics() {
        guard topics.isEmpty else {
            tableView.reloadData()
            return
        }
        web.request(.storyTopics, responseType: Response<TopicListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .failure(error):
                logger.error(error)
            case let .success(response):
                logger.debug(response)
                self.topics = response.tags
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPressCloseButton() {
        var topic: String?
        if let indexPath = allSelectedIndexPath {
            topic = topics[indexPath.row]
        }
        onFinished?(topic)
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
}

extension TopicListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return topics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TopicCell else {
            fatalError()
        }
        let topic = topics[indexPath.row]
        cell.topic = topic
        return cell
    }
}

extension TopicListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.setSelected(allSelectedIndexPath == indexPath, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedIndexPath: IndexPath?
        selectedIndexPath = allSelectedIndexPath
        allSelectedIndexPath = indexPath
        var reloadRows = [indexPath]
        if let selected = selectedIndexPath {
            if selected.row == indexPath.row {
                allSelectedIndexPath = nil
            }
            reloadRows.append(selected)
        }
        tableView.reloadRows(at: reloadRows, with: .none)
    }
}
