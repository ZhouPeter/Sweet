//
//  ConversationController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/1.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import MessageKit

final class ConversationController: MessagesViewController {
    private let userID: UInt64
    private let conversation: Conversation
    
    private lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    private var messages = [InstantMessage]()
    
    init(userID: UInt64, conversation: Conversation) {
        self.userID = userID
        self.conversation = conversation
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = conversation.username
        
        setupCollectionView()
        setupInputBar()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
    }
    
    // MARK: - Private
    
    private func setupCollectionView() {
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
}

extension ConversationController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: "\(userID)", displayName: "我啊")
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
        avatarView.set(avatar: Avatar(image: #imageLiteral(resourceName: "Logo"), initials: "M"))
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
        var message = InstantMessage(from: userID, to: conversation.userID, type: .text)
        message.content = text
        messages.append(message)
        messagesCollectionView.insertSections([messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom()
    }
}
