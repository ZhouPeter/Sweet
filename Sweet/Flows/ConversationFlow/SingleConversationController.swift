//
//  ConversationController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/1.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import SDWebImage
import STPopupPreview

protocol SingleConversationView: BaseView {
    var delegate: ConversationControllerDelegate? { get set }
}

final class SingleConversationController: ConversationViewController, SingleConversationView {
    private var buddy: User
    
    init(user: User, buddy: User) {
        self.buddy = buddy
        super.init(user: user)
        members[buddy.userId] = buddy
        Messenger.shared.addDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = buddy.nickname
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: #imageLiteral(resourceName: "Menu_black"), style: .plain, target: self, action: #selector(didPressRightBarButton))
        Messenger.shared.loadMessages(from: buddy)
    }
    
    override func didBlock(userID: UInt64) {
        buddy.isBlacklisted = true
        let controller = UIAlertController(title: "是否举报该用户", message: nil, preferredStyle: .alert)
        controller.view.tintColor = .black
        controller.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { (_) in
            self.delegate?.conversationControllerReports(buddy: self.buddy)
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    override func didUnblock(userID: UInt64) {
        buddy.isBlacklisted = false
    }
    
    override func loadMoreMessages() {
        guard messages.isNotEmpty else {
            logger.debug("messages is empty")
            Messenger.shared.fetchRecentMessages(from: buddy)
            return
        }
        guard let message = getLastSentMessage() else {
            logger.debug("lastMessage is nil")
            refreshControl.endRefreshing()
            return
        }
        Messenger.shared.loadMoreMessages(from: buddy, lastMessage: message)
    }
    
    @objc private func didPressRightBarButton() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .black
        controller.addAction(UIAlertAction(title: "查看主页", style: .default, handler: { (_) in
            self.delegate?.conversationControllerShowsProfile(buddy: self.buddy)
        }))
        controller.addAction(UIAlertAction(title: "举报", style: .default, handler: { (_) in
            self.delegate?.conversationControllerReports(buddy: self.buddy)
        }))
        if buddy.isBlacklisted == true {
            controller.addAction(UIAlertAction(title: "解除黑名单", style: .destructive, handler: { (_) in
                self.delegate?.conversationController(self, unblocksBuddy: self.buddy)
            }))
        } else {
            controller.addAction(UIAlertAction(title: "加入黑名单", style: .destructive, handler: { (_) in
                self.delegate?.conversationController(self, blocksBuddy: self.buddy)
            }))
        }
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
}

extension SingleConversationController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Messenger.shared.sendText(text, from: user.userId, to: buddy.userId)
        messages.append(message)
        messagesCollectionView.insertSections([messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension SingleConversationController: MessengerDelegate {
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User) {
        guard buddy.userId == self.buddy.userId else { return }
        self.messages = messages
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        guard message.from == user.userId, message.to == buddy.userId else { return }
        if let section = messages.index(where: { $0.localID == message.localID }) {
            let indexPath = IndexPath(row: 0, section: section)
            messages[indexPath.section] = message
            messagesCollectionView.reloadSections([section])
        } else {
            messages.append(message)
            messagesCollectionView.insertSections([messages.count - 1])
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func messengerDidReceiveMessage(_ message: InstantMessage) {
        guard message.from == buddy.userId, message.to == user.userId else { return }
        self.messages.append(message)
        messagesCollectionView.insertSections([self.messages.count - 1])
        messagesCollectionView.scrollToBottom(animated: true)
    }

    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], buddy: User) {
        defer { refreshControl.endRefreshing() }
        guard messages.isNotEmpty, buddy.userId == self.buddy.userId else { return }
        self.messages.insert(contentsOf: messages, at: 0)
        messagesCollectionView.reloadDataAndKeepOffset()
    }
}
