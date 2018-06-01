//
//  InboxController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/4/23.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import SwipeCellKit

final class InboxController: BaseViewController, InboxView {
    weak var delegate: InboxViewDelegate?
    private var conversations = [Conversation]()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.dataSource = self
        view.delegate = self
        view.register(cellType: ConversationCell.self)
        view.separatorInset.left = 0
        view.sectionHeaderHeight = 8
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        return view
    } ()
    
    private var isCellSwiping = false
    
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
        cell.delegate = self
        cell.gestureRecognizers?.forEach({ (gesture) in
            if gesture is UIPanGestureRecognizer {
                gesture.delegate = self
            }
        })
        return cell
    }
}

extension InboxController: UIGestureRecognizerDelegate {
    func gestureRecognizer(
        _ gestureRecognizer: UIGestureRecognizer,
        shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension InboxController: SwipeTableViewCellDelegate {
    func tableView(
        _ tableView: UITableView,
        editActionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        guard orientation == .right else { return nil }
        let deleteAction = SwipeAction(style: .destructive, title: "删除") { [weak self] (_, indexPath) in
            guard let `self` = self else { return }
            self.conversations.remove(at: indexPath.row)
            self.delegate?.inboxRemoveConversation(userID: self.conversations[indexPath.row].userID)
        }
        return [deleteAction]
    }
    
    func tableView(
        _ tableView: UITableView,
        editActionsOptionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .destructive
        return options
    }
    
    func tableView(
        _ tableView: UITableView,
        willBeginEditingRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation) {
        NotificationCenter.default.post(name: .DisablePageScroll, object: nil)
    }
    
    func tableView(
        _ tableView: UITableView,
        didEndEditingRowAt indexPath: IndexPath?,
        for orientation: SwipeActionsOrientation) {
        NotificationCenter.default.post(name: .EnablePageScroll, object: nil)
    }
}

extension InboxController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 68
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 8
    }
}
