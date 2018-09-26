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
    private var conversations = [IMConversation]()
    private let headerView = WarningHeaderView()
    
    private lazy var tableView: UITableView = {
        let view = UITableView(frame: .zero, style: .grouped)
        view.dataSource = self
        view.delegate = self
        view.register(cellType: ConversationCell.self)
        view.backgroundColor = .clear
        view.separatorColor = UIColor(hex: 0xF2F2F2)
        view.separatorInset = UIEdgeInsets(top: 0, left: 70, bottom: 0, right: 0)
        return view
    } ()
    
    private var isCellSwiping = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        view.addSubview(tableView)
        tableView.fill(in: view)
        if #available(iOS 11.0, *) {
            tableView.contentInsetAdjustmentBehavior = .never
        } else {
            automaticallyAdjustsScrollViewInsets = false
        }
        headerView.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: 40)
        tableView.tableHeaderView = headerView
    }
    
    func didUpdateConversations(_ conversations: [IMConversation]) {
        DispatchQueue.main.throttle(deadline: .now() + 0.15) {
            self.conversations = conversations.sorted(by: { $0.lastMessageTimestamp > $1.lastMessageTimestamp })
            self.tableView.reloadData()
        }
    }
    
    func didUpdateUserOnlineState(isUserOnline: Bool) {
        if isUserOnline {
            headerView.frame.size.height = 0.01
            headerView.isHidden = true
        } else {
            headerView.frame.size.height = 40
            headerView.isHidden = false
        }
        tableView.tableHeaderView = headerView
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
        shouldRequireFailureOf otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        if otherGestureRecognizer.view == tableView {
            return true
        }
        return false
    }
    
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
            let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            sheet.addAction(UIAlertAction(title: "确认删除", style: .destructive, handler: { (_) in
                let conversaion = self.conversations.remove(at: indexPath.row)
                self.delegate?.inboxRemoveConversation(conversaion)
                self.tableView.reloadData()
            }))
            sheet.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
            self.present(sheet, animated: true, completion: nil)
        }
        return [deleteAction]
    }
    
    func tableView(
        _ tableView: UITableView,
        editActionsOptionsForRowAt indexPath: IndexPath,
        for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = SwipeExpansionStyle(
            target: .percentage(0.5),
            elasticOverscroll: false,
            completionAnimation: .bounce
        )
        options.transitionStyle = .drag
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
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        delegate?.inboxStartConversation(conversations[indexPath.row])
    }
}
