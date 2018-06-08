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
import STPopupPreview

final class ConversationController: MessagesViewController {
    private let user: User
    private let buddy: User
    private let refreshControl = UIRefreshControl()
    private var messages = [InstantMessage]()
    
    init(user: User, buddy: User) {
        self.user = user
        self.buddy = buddy
        super.init(nibName: nil, bundle: nil)
        Messenger.shared.startConversation(userID: buddy.userId)
        Messenger.shared.addDelegate(self)
        Messenger.shared.loadMessages(from: buddy)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        let layout = SweetMessagesFlowLayout()
        let avatarPosition = AvatarPosition(vertical: .cellTop)
        layout.textMessageSizeCalculator.incomingAvatarPosition = avatarPosition
        layout.textMessageSizeCalculator.outgoingAvatarPosition = avatarPosition
        layout.sizeCalculator.incomingAvatarPosition = avatarPosition
        layout.sizeCalculator.outgoingAvatarPosition = avatarPosition
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: layout)
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = buddy.nickname
        
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
    
    deinit {
        logger.debug()
        Messenger.shared.endConversation(userID: buddy.userId)
    }
    
    // MARK: - Private
    
    private func setupCollectionView() {
        messagesCollectionView.register(StoryMessageCell.self)
        messagesCollectionView.register(OptionCardMessageCell.self)
        messagesCollectionView.register(ContentCardMessageCell.self)
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messageCellDelegate = self
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

    override func collectionView(
        _ collectionView: UICollectionView,
        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let message = messages[indexPath.section]
        guard case let .custom(value) = message.kind else {
            return super.collectionView(collectionView, cellForItemAt: indexPath)
        }
        if value is StoryMessageContent {
            let cell = messagesCollectionView.dequeueReusableCell(StoryMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        if value is OptionCardContent {
            let cell = messagesCollectionView.dequeueReusableCell(OptionCardMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            if cell.popupPreviewRecognizer == nil {
                cell.popupPreviewRecognizer = STPopupPreviewRecognizer(delegate: self)
            }
            return cell
        }
        if value is ContentCardContent {
            let cell = messagesCollectionView.dequeueReusableCell(ContentCardMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
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
    
//    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
//        return NSAttributedString(
//            string: "下午 4:59",
//            attributes: [
//                .font: UIFont.systemFont(ofSize: 12),
//                .foregroundColor: UIColor.lightGray
//            ]
//        )
//    }
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

//    func cellTopLabelHeight(
//        for message: MessageType,
//        at indexPath: IndexPath,
//        in messagesCollectionView: MessagesCollectionView) -> CGFloat {
//        return 25
//    }
}

extension ConversationController: MessagesLayoutDelegate {}

extension ConversationController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        guard message.type == .card else { return }
        if let content = message.content as? OptionCardContent {
            let preview = OptionCardPreviewController(content: content)
            let popup = PopupController(rootViewController: preview)
            popup.present(in: self)
        }
    }
}

extension ConversationController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Messenger.shared.sendText(text, from: user.userId, to: buddy.userId)
        messages.append(message)
        messagesCollectionView.insertSections([messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension ConversationController: MessengerDelegate {
    func messengerDidLoadMessages(_ messages: [InstantMessage], buddy: User) {
        guard buddy.userId == self.buddy.userId else { return }
        self.messages = messages
        messagesCollectionView.reloadData()
        let contentHeight = messagesCollectionView.collectionViewLayout.collectionViewContentSize.height
        let visibleHeight = messagesCollectionView.bounds.size.height - messageInputBar.bounds.height
        if contentHeight > visibleHeight {
            self.messagesCollectionView.contentOffset = CGPoint(x: 0, y: contentHeight - visibleHeight)
        }
    }
    
    func messengerDidSendMessage(_ message: InstantMessage, success: Bool) {
        
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

extension ConversationController: STPopupPreviewRecognizerDelegate {
    func previewViewController(for popupPreviewRecognizer: STPopupPreviewRecognizer) -> UIViewController? {
        guard
            let cell = popupPreviewRecognizer.view as? UICollectionViewCell,
            let indexPath = messagesCollectionView.indexPath(for: cell)
        else {
            return nil
        }
        let message = messages[indexPath.section]
        if let content = message.content as? OptionCardContent {
            return OptionCardPreviewController(content: content)
        }
        return nil
    }
    
    func presentingViewController(for popupPreviewRecognizer: STPopupPreviewRecognizer) -> UIViewController {
        return self
    }
    
    func previewActions(for popupPreviewRecognizer: STPopupPreviewRecognizer) -> [STPopupPreviewAction] {
        return []
    }
}
