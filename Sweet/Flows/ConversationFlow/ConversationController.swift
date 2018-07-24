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
import JXPhotoBrowser

protocol ConversationView: BaseView {
    var delegate: ConversationControllerDelegate? { get set }
}

final class ConversationController: MessagesViewController, ConversationView {
    weak var delegate: ConversationControllerDelegate?
    private var photoBrowserDelegate: PhotoBrowserImp?
    private let user: User
    private var buddy: User
    private let refreshControl = UIRefreshControl()
    private var messages = [InstantMessage]()
    private var inComingBubbleMaskImage: UIImage = {
        guard let image = UIImage.bubbleImage(named: "MessageBubble", orientation: .upMirrored) else { fatalError() }
        return image
    } ()
    private var outgoingBubbleMaskImage: UIImage = {
        guard let image = UIImage.bubbleImage(named: "MessageBubble", orientation: .up) else { fatalError() }
        return image
    } ()
    private var incommingBubbleMaskCache = [UIView: UIImageView]()
    private var outgoingBubbleMaskCache = [UIView: UIImageView]()
    
    init(user: User, buddy: User) {
        self.user = user
        self.buddy = buddy
        super.init(nibName: nil, bundle: nil)
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
        layout.emojiMessageSizeCalculator.incomingAvatarPosition = avatarPosition
        layout.emojiMessageSizeCalculator.outgoingAvatarPosition = avatarPosition
        layout.sizeCalculator.incomingAvatarPosition = avatarPosition
        layout.sizeCalculator.outgoingAvatarPosition = avatarPosition
        let accessoryViewSize = CGSize(width: 35, height: 35)
        layout.setMessageIncomingAccessoryViewSize(accessoryViewSize)
        layout.setMessageOutgoingAccessoryViewSize(accessoryViewSize)
        messagesCollectionView = MessagesCollectionView(frame: .zero, collectionViewLayout: layout)
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        title = buddy.nickname
        
        setupCollectionView()
        setupInputBar()
        navigationItem.rightBarButtonItem =
            UIBarButtonItem(image: #imageLiteral(resourceName: "Menu_black"), style: .plain, target: self, action: #selector(didPressRightBarButton))
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        guard parent == nil else { return }
        delegate?.conversationDidFinish()
    }
    
    func didBlock() {
        buddy.isBlacklisted = true
        let controller = UIAlertController(title: "是否举报该用户", message: nil, preferredStyle: .alert)
        controller.view.tintColor = .black
        controller.addAction(UIAlertAction(title: "举报", style: .destructive, handler: { (_) in
            self.delegate?.conversationControllerReports(buddy: self.buddy)
        }))
        controller.addAction(UIAlertAction(title: "取消", style: .cancel, handler: nil))
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: - Private
    
    private func setupCollectionView() {
        messagesCollectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        messagesCollectionView.register(StoryMessageCell.self)
        messagesCollectionView.register(OptionCardMessageCell.self)
        messagesCollectionView.register(ContentCardMessageCell.self)
        messagesCollectionView.register(SweetTextMessageCell.self)
        messagesCollectionView.register(ImageMessageCell.self)
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
        messageInputBar.padding.right = 2
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
        if case .text = message.kind {
            let cell = messagesCollectionView.dequeueReusableCell(SweetTextMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            if message.sender.id == "\(user.userId)" {
                cell.configureGradientColors([UIColor(hex: 0x66e5ff), UIColor(hex: 0x36c6fd)])
            } else {
                cell.configureGradientColors([UIColor.white, UIColor.white])
            }
            return cell
        }
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
        if value is ImageMessageContent {
            let cell = messagesCollectionView.dequeueReusableCell(ImageMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    private func makeBubbleMask(isIncomming: Bool) -> UIImageView {
        if isIncomming {
            return UIImageView(image: inComingBubbleMaskImage)
        }
        return UIImageView(image: outgoingBubbleMaskImage)
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
        return .custom({ [weak self] (container) in
            guard let `self` = self else { return }
            let isIncomming = message.sender.id == "\(self.buddy.userId)"
            let mask: UIImageView
            if isIncomming {
                if let maskView = self.incommingBubbleMaskCache[container] {
                    mask = maskView
                } else {
                    mask = self.makeBubbleMask(isIncomming: true)
                    self.incommingBubbleMaskCache[container] = mask
                }
            } else {
                if let maskView = self.outgoingBubbleMaskCache[container] {
                    mask = maskView
                } else {
                    mask = self.makeBubbleMask(isIncomming: false)
                    self.outgoingBubbleMaskCache[container] = mask
                }
            }
            mask.frame = container.bounds
            container.mask = mask
        })
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
        if message.sender.id == "\(user.userId)" {
            return .white
        }
        return .black
    }
    
    func avatarSize(
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func configureAccessoryView(
        _ accessoryView: UIView,
        for message: MessageType,
        at indexPath: IndexPath,
        in messagesCollectionView: MessagesCollectionView) {
        let imMessage = messages[indexPath.section]
        let resendButton = addAccessoryResendButtonIfNeeds(accessoryView)
        resendButton.isHidden = true
        resendButton.indexPath = indexPath
        let indicator = addAccessoryIndicatorIfNeeds(accessoryView)
        indicator.stopAnimating()
        if imMessage.from == user.userId, imMessage.isSent == false {
            if imMessage.isFailed {
                resendButton.isHidden = false
            } else {
                indicator.isHidden = false
                indicator.startAnimating()
            }
        }
    }
    
    @discardableResult private func addAccessoryIndicatorIfNeeds(_ accessoryView: UIView) -> UIActivityIndicatorView {
        let tag = 2
        if let indicator = accessoryView.viewWithTag(tag) as? UIActivityIndicatorView {
            return indicator
        }
        let indicator = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        accessoryView.addSubview(indicator)
        indicator.align(.left)
        indicator.align(.right)
        indicator.align(.bottom)
        indicator.align(.top, to: accessoryView, inset: 10, priority: .defaultHigh)
        indicator.tag = tag
        indicator.hidesWhenStopped = true
        indicator.stopAnimating()
        return indicator
    }
    
    @discardableResult private func addAccessoryResendButtonIfNeeds(_ accessoryView: UIView) -> IndexPathButton {
        let tag = 1
        if let button = accessoryView.viewWithTag(tag) as? IndexPathButton {
            return button
        }
        let button = IndexPathButton()
        button.tag = tag
        button.setImage(UIImage(named: "Failed"), for: .normal)
        accessoryView.addSubview(button)
        button.align(.left)
        button.align(.right)
        button.align(.bottom)
        button.align(.top, to: accessoryView, inset: 10, priority: .defaultHigh)
        button.isHidden = true
        button.addTarget(self, action: #selector(didPressResendButton(button:)), for: .touchUpInside)
        return button
    }
    
    @objc private func didPressResendButton(button: IndexPathButton) {
        guard let indexPath = button.indexPath else { return }
        var message = messages[indexPath.section]
        message.isFailed = false
        messages[indexPath.section] = message
        messagesCollectionView.reloadSections([indexPath.section])
        Messenger.shared.send(message)
    }
}

extension ConversationController: MessagesLayoutDelegate {}

extension ConversationController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        let message = messages[indexPath.section]
        if let content = message.content as? ImageMessageContent,
            let cell = cell as? ImageMessageCell, message.type == .image {
            let browserDelegate =
                PhotoBrowserImp(thumbnaiImageViews: [cell.imageView], highImageViewURLs: [URL(string: content.url)!])
            photoBrowserDelegate = browserDelegate
            let browser = CustomPhotoBrowser(delegate: browserDelegate, originPageIndex: 0)
            browser.animationType = .scale
            browser.plugins.append(CustomNumberPageControlPlugin())
            browser.show()
            return
        }
        guard message.type == .card || message.type == .story else { return }
        if let content = message.content as? OptionCardContent {
            let preview = OptionCardPreviewController(content: content)
            let popup = PopupController(rootViewController: preview)
            popup.present(in: self)
        } else if let content = message.content as? ContentCardContent {
            let preview = WebViewController(urlString: content.url)
            navigationController?.pushViewController(preview, animated: true)
        } else if let content = message.content as? StoryMessageContent {
            web.request(
                .getStory(storyID: content.identifier),
                responseType: Response<StoryGetResponse>.self
            ) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    logger.error(error)
                case .success(let response):
                    self.delegate?.conversationControllerShowsStory(
                        StoryCellViewModel(model: response.story),
                        user: message.from == self.user.userId ? self.user : self.buddy,
                        messageId: message.messageId
                    )
                    if let cell = cell as? StoryMessageCell {
                        cell.thumbnailImageView.hero.isEnabled = true
                        cell.thumbnailImageView.hero.id = "\(response.story.userId)" + message.messageId
                        cell.thumbnailImageView.hero.modifiers = [.arc]
                    }
                }
            }
        }
    }

    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        if messages[indexPath.section].sender.id == "\(user.userId)" {
            delegate?.conversationControllerShowsProfile(buddy: user)
        } else {
            delegate?.conversationControllerShowsProfile(buddy: buddy)
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
        guard let section = messages.firstIndex(where: { $0.localID == message.localID }) else  { return }
        let indexPath = IndexPath(row: 0, section: section)
        messages[indexPath.section] = message
        messagesCollectionView.reloadSections([section])
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
