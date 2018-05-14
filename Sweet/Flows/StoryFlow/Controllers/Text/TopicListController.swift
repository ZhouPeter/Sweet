//
//  TopicListController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicListController: UIViewController {
    var didFinish: ((String?) -> Void)?
    
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
    
    private var topics = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .clear
        view.addSubview(tableView)
        tableView.fill(in: view)
        let inset: CGFloat = 56
        tableView.contentInset = UIEdgeInsets(top: inset, left: 0, bottom: 0, right: 0)
        tableView.contentOffset = CGPoint(x: 0, y: -inset)
        for _ in 0...20 {
            topics.append("#话题话题话题话题#")
        }
        
        let closeButton = UIButton(type: .custom)
        closeButton.setImage(#imageLiteral(resourceName: "StoryClose"), for: .normal)
        closeButton.addTarget(self, action: #selector(didPressCloseButton), for: .touchUpInside)
        view.addSubview(closeButton)
        closeButton.align(.top, to: view, inset: 10)
        closeButton.align(.right, to: view, inset: 10)
        closeButton.constrain(width: 30, height: 30)
    }
    
    // MARK: - Actions
    
    @objc private func didPressCloseButton() {
        didFinish?(nil)
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
        return cell
    }
}

extension TopicListController: UITableViewDelegate {
    
}
