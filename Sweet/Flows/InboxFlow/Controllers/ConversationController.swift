//
//  ConversationController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/1.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import Kingfisher

final class ConversationController: MessagesViewController {
    private let user: User
    private let buddy: User
    private let refreshControl = UIRefreshControl()
    private var messages = [InstantMessage]()
    
    init(user: User, buddy: User) {
        self.user = user
        self.buddy = buddy
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = buddy.nickname
        
        setupCollectionView()
        setupInputBar()
        Messenger.shared.startConversation(userID: buddy.userId)
        Messenger.shared.addDelegate(self)
        Messenger.shared.loadMessages(from: buddy)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
    }
    
    deinit {
        logger.debug()
        Messenger.shared.endConversation(userID: buddy.userId)
    }
    
    // MARK: - Private
    
    private func setupCollectionView() {
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        if let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout {
            let avatarPosition = AvatarPosition(vertical: .cellTop)
            layout.textMessageSizeCalculator.incomingAvatarPosition = avatarPosition
            layout.textMessageSizeCalculator.outgoingAvatarPosition = avatarPosition
        }
    }
    
    private func setupInputBar() {
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.delegate = self
        messageInputBar.isTranslucent = false
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "SendButton"), for: .normal)
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "SendButtonDisabled"), for: .disabled)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.placeholder = "说点什么"
        messageInputBar.inputTextView.layer.borderWidth = 0
    }

    @objc private func loadMoreMessages() {
        guard messages.isNotEmpty else {
            logger.debug("messages is empty")
            refreshControl.endRefreshing()
            return
        }
        var lastMessage: InstantMessage?
        for index in 0..<messages.count {
            let message = messages[index]
            if message.remoteID != nil {
                lastMessage = message
                break
            }
        }
        guard let message = lastMessage else {
            logger.debug("lastMessage is nil")
            refreshControl.endRefreshing()
            return
        }
        Messenger.shared.loadMoreMessages(from: buddy, lastMessage: message)
    }
}

extension ConversationController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: "\(user.userId)", displayName: user.nickname)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }

    func configureAvatarView(
        _ avatarView: AvatarView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        avatarView.placeholderTextColor = .gray
        avatarView.backgroundColor = .clear
        let avatarURLString = message.sender.id == "\(user.userId)" ? user.avatar : buddy.avatar
        avatarView.kf.setImage(with: URL(string: avatarURLString), placeholder: #imageLiteral(resourceName: "Logo"))
    }
}

extension ConversationController: MessagesDisplayDelegate {
    func messageStyle(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .bubble
    }
    
    func backgroundColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    func textColor(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .black
    }
}

extension ConversationController: MessagesLayoutDelegate {
    
}

extension ConversationController: MessageCellDelegate {
    
}

extension ConversationController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Messenger.shared.sendText(text, from: user.userId, to: buddy.userId)
        messages.append(message)
        messagesCollectionView.insertSections([messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom()
    }
}

extension ConversationController: MessengerDelegate {
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User) {
        guard buddy.userId == self.buddy.userId else { return }
        self.messages = messages
        messagesCollectionView.reloadData()
        messagesCollectionView.scrollToBottom()
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        
    }
    
    func messengerDidReceiveMessage(_ message: InstantMessage) {
        guard message.from == buddy.userId else { return }
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
