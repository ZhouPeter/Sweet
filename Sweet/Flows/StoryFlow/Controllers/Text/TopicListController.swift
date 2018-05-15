//
//  TopicListController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicListController: UIViewController {
    var didFinish: ((Topic?) -> Void)?
    
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
        allButton.setTitle("全部", for: .normal)
        allButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        allButton.setTitleColor(.white, for: .normal)
        allButton.addTarget(self, action: #selector(didPressAllButton), for: .touchUpInside)
        return allButton
    } ()
    
    private lazy var recentButton: UIButton = {
        let recentButton = UIButton(type: .custom)
        recentButton.setTitle("常用", for: .normal)
        recentButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        recentButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        recentButton.addTarget(self, action: #selector(didPressRecentButton), for: .touchUpInside)
        return recentButton
    } ()
    
    private var allSelectedIndexPath: IndexPath?
    private var recentSelectedIndexPath: IndexPath?
    private var allTopics = [Topic]()
    private var recentTopics = [Topic]()
    private var isAll = true
    
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
        view.addSubview(closeButton)
        closeButton.align(.top, to: view, inset: 10)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.constrain(width: 30, height: 30)
        
        view.addSubview(allButton)
        allButton.constrain(width: 50, height: 40)
        allButton.centerX(to: view, offset: -30)
        allButton.align(.top, to: view, inset: 8)
        
        view.addSubview(recentButton)
        recentButton.constrain(width: 50, height: 40)
        recentButton.centerX(to: view, offset: 30)
        recentButton.align(.top, to: view, inset: 8)
        
        loadAllTopics()
    }
    
    // MARK: - Private
    
    private func loadAllTopics() {
        guard allTopics.isEmpty else {
            isAll = true
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
                self.allTopics = response.list
                self.isAll = true
                self.tableView.reloadData()
            }
        }
    }
    
    private func loadRecentTopics() {
        guard recentTopics.isEmpty else {
            isAll = false
            tableView.reloadData()
            return
        }
        web.request(.storyRecentTopics, responseType: Response<TopicListResponse>.self) { [weak self] (result) in
            guard let `self` = self else { return }
            switch result {
            case let .failure(error):
                logger.error(error)
            case let .success(response):
                logger.debug(response)
                self.allTopics = response.list
                self.isAll = false
                self.tableView.reloadData()
            }
        }
    }
    
    // MARK: - Actions
    
    @objc private func didPressCloseButton() {
        var topic: Topic?
        if isAll {
            if let indexPath = allSelectedIndexPath {
                topic = allTopics[indexPath.row]
            }
        } else if let indexPath = recentSelectedIndexPath {
            topic = recentTopics[indexPath.row]
        }
        didFinish?(topic)
        willMove(toParentViewController: nil)
        view.removeFromSuperview()
        removeFromParentViewController()
        didMove(toParentViewController: nil)
    }
    
    @objc private func didPressAllButton() {
        allButton.setTitleColor(.white, for: .normal)
        recentButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        loadAllTopics()
    }
    
    @objc private func didPressRecentButton() {
        allButton.setTitleColor(UIColor(white: 1, alpha: 0.5), for: .normal)
        recentButton.setTitleColor(.white, for: .normal)
        loadRecentTopics()
    }
}

extension TopicListController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isAll ? allTopics.count : recentTopics.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? TopicCell else {
            fatalError()
        }
        let topic: Topic
        if isAll {
            topic = allTopics[indexPath.row]
        } else {
            topic = recentTopics[indexPath.row]
        }
        cell.topicLabel.text = topic.content
        return cell
    }
}

extension TopicListController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        var isSelected = false
        if isAll {
            isSelected = allSelectedIndexPath == indexPath
        } else {
            isSelected = recentSelectedIndexPath == indexPath
        }
        logger.debug(isSelected, indexPath.row)
        cell.setSelected(isSelected, animated: false)
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        var selectedIndexPath: IndexPath?
        if isAll {
            selectedIndexPath = allSelectedIndexPath
            allSelectedIndexPath = indexPath
        } else {
            selectedIndexPath = recentSelectedIndexPath
            recentSelectedIndexPath = indexPath
        }
        var reloadRows = [indexPath]
        if let selected = selectedIndexPath {
            if selected.row == indexPath.row {
                allSelectedIndexPath = nil
                recentSelectedIndexPath = nil
            }
            reloadRows.append(selected)
        }
        if isAll {
            recentSelectedIndexPath = nil
        } else {
            allSelectedIndexPath = nil
        }
        tableView.reloadRows(at: reloadRows, with: .none)
    }
}
