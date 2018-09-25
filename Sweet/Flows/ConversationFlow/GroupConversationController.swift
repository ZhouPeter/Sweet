//
//  GroupConversationController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/19.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import PKHUD

protocol GroupConversationView: BaseView {
    
}

final class GroupConversationController: ConversationViewController, GroupConversationView {
    private var group: Group
    
    init(user: User, group: Group) {
        self.group = group
        super.init(user: user)
        Messenger.shared.addDelegate(self)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = "\(group.name) (\(group.memberCount)人)"
        messageInputBar.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named: "Quit"),
                                                            style: .plain,
                                                            target: self,
                                                            action: #selector(didPressRightBarButton))
        Messenger.shared.loadMessages(from: group)
    }
    
    @objc private func didPressRightBarButton() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .black
        controller.addAction(
            UIAlertAction(title: group.isMuted ? "关闭消息免打扰" : "消息免打扰", style: .default, handler: { [weak self] _ in
                guard let self = self else { return }
                HUD.show(.systemActivity)
                Messenger.shared.muteGroup(self.group, isMuted: !self.group.isMuted)
            })
        )
        controller.addAction(UIAlertAction(title: "删除并退出群聊", style: .destructive, handler: { [weak self] (_) in
            guard let self = self else { return }
            HUD.show(.systemActivity)
            Messenger.shared.quitGroup(self.group)
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    override func loadMoreMessages() {
        guard messages.isNotEmpty else {
            logger.debug("messages is empty")
            Messenger.shared.fetchRecentMessages(from: group)
            return
        }
        guard let message = getLastSentMessage() else {
            logger.debug("lastMessage is nil")
            refreshControl.endRefreshing()
            return
        }
        Messenger.shared.loadMoreMessages(from: group, lastMessage: message)
    }
    
    override func loadMember(_ userID: UInt64, callback: @escaping ((User?) -> Void)) {
        Messenger.shared.loadUserWith(id: userID) { [weak self] (user) in
            guard let user = user else {
                logger.error("Load user failed: \(userID)")
                callback(nil)
                return
            }
            self?.members[userID] = user
            callback(user)
        }
    }
}

extension GroupConversationController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Messenger.shared.sendText(text, from: user.userId, to: group.id, isGroup: true)
        messages.append(message)
        messagesCollectionView.insertSections([messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension GroupConversationController: MessengerDelegate {
    func messengerDidLoadMessages(_ messages: [InstantMessage], group: Group) {
        guard group.id == self.group.id else { return }
        self.messages = messages
        messagesCollectionView.reloadData()
        let contentHeight = messagesCollectionView.collectionViewLayout.collectionViewContentSize.height
        let visibleHeight = messagesCollectionView.bounds.size.height - messageInputBar.bounds.height
        if contentHeight > visibleHeight {
            messagesCollectionView.contentOffset = CGPoint(x: 0, y: contentHeight - visibleHeight)
        }
    }
    
    func messengerDidLoadMoreMessages(_ messages: [InstantMessage], group: Group) {
        guard group.id == self.group.id else { return }
        refreshControl.endRefreshing()
        guard messages.isNotEmpty else { return }
        self.messages.insert(contentsOf: messages, at: 0)
        messagesCollectionView.reloadDataAndKeepOffset()
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        guard message.from == user.userId, message.to == group.id else { return }
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
        guard message.to == group.id else { return }
        self.messages.append(message)
        messagesCollectionView.insertSections([self.messages.count - 1])
        messagesCollectionView.scrollToBottom(animated: true)
    }
    
    func messengerDidQuitGroup(_ groupID: UInt64, success: Bool) {
        guard groupID == group.id else { return }
        if success {
            HUD.hide()
            navigationController?.popViewController(animated: true)
        } else {
            HUD.flash(.label("退出失败，请重试"), delay: 2, completion: nil)
        }
    }
    
    func messengerDidMuteGroup(_ groupID: UInt64, isMuted: Bool) {
        guard groupID == group.id else { return }
        if isMuted == group.isMuted {
            HUD.flash(.label("操作失败，请重试"), delay: 2, completion: nil)
        } else {
            HUD.hide()
            group.isMuted = isMuted
        }
    }
}