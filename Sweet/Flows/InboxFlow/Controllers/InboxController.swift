//
//  InboxController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class InboxController: BaseViewController, InboxView {
    weak var delegate: InboxViewDelegate?
    private var conversations = [Conversation]()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .plain)
        view.dataSource = self
        view.delegate = self
        view.register(cellType: ConversationCell.self)
        return view
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fill(in: view)
    }
    
    func didUpdateConversations(_ conversations: [Conversation]) {
        self.conversations = conversations
        tableView.reloadData()
    }
}

extension InboxController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ConversationCell.self)
        cell.updateWith(conversations[indexPath.row])
        return cell
    }
}

extension InboxController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
}
