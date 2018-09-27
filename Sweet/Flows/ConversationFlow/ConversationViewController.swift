//
//  ConversationBaseViewController.swift
//  Sweet
//
//  Created by Mario Z. on 2018/9/19.
//  Copyright © 2018 Miaozan. All rights reserved.
//

import UIKit
import MessageKit
import STPopupPreview
import SDWebImage
import JXPhotoBrowser

class ConversationViewController: MessagesViewController {
    weak var delegate: ConversationControllerDelegate?
    let user: User
    var members = [UInt64: User]()
    var photoBrowserDelegate: PhotoBrowserImp?
    let refreshControl = UIRefreshControl()
    var messages = [InstantMessage]()
    var inComingBubbleMaskImage = UIImage.bubbleImage(named: "MessageBubble", orientation: .upMirrored)!
    var outgoingBubbleMaskImage = UIImage.bubbleImage(named: "MessageBubble", orientation: .up)!
    var incommingBubbleMaskCache = [UIView: UIImageView]()
    var outgoingBubbleMaskCache = [UIView: UIImageView]()
    var contentInsetBottom: CGFloat?
    var contentOffset: CGPoint?
    
    // MARK: - Life Cycle
    
    init(user: User) {
        self.user = user
        super.init(nibName: nil, bundle: nil)
        members[user.userId] = user
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        resplaceWithSweetCollectionView()
        super.viewDidLoad()
        view.backgroundColor = UIColor(hex: 0xF2F2F2)
        setupCollectionView()
        setupInputBar()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.barTintColor = .white
        navigationController?.navigationBar.barStyle = .default
        navigationController?.navigationBar.tintColor = .black
        NotificationCenter.default.post(name: .BlackStatusBar, object: nil)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let bottom = contentInsetBottom {
            messagesCollectionView.contentInset.bottom = bottom
            messagesCollectionView.scrollIndicatorInsets.bottom = bottom
            if let offset = contentOffset {
                messagesCollectionView.contentOffset = offset
                contentOffset = nil
            }
            contentInsetBottom = nil
        }
    }
    
    override func willMove(toParentViewController parent: UIViewController?) {
        super.willMove(toParentViewController: parent)
        guard parent == nil else { return }
        delegate?.conversationDidFinish()
    }
    
    override func collectionView(_ collectionView: UICollectionView,
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
        if value is ArticleMessageContent {
            let cell = messagesCollectionView.dequeueReusableCell(ArticleMessageCell.self, for: indexPath)
            cell.configure(with: message, at: indexPath, and: messagesCollectionView)
            return cell
        }
        return super.collectionView(collectionView, cellForItemAt: indexPath)
    }
    
    // MARK: - Public
    
    func loadMember(_ userID: UInt64, callback: @escaping ((User?) -> Void)) {
        
    }
    
    @objc func loadMoreMessages() {
        
    }
    
    func getLastSentMessage() -> InstantMessage? {
        var lastMessage: InstantMessage?
        for index in 0..<messages.count {
            let message = messages[index]
            if message.remoteID != nil {
                lastMessage = message
                break
            }
        }
        return lastMessage
    }
    
    private var lastReloadDate: Date?
    private let realodDelay: TimeInterval = 0.2
    
    func reloadDataAndGoToBottom() {
        let now = Date()
        if let last = lastReloadDate, now.timeIntervalSince(last) < realodDelay {
            DispatchQueue.main.asyncAfter(deadline: .now() + realodDelay) {
                self.reloadDataAndGoToBottom()
            }
            return
        }
        lastReloadDate = Date()
        self.messagesCollectionView.reloadData()
        let contentHeight = self.messagesCollectionView.collectionViewLayout.collectionViewContentSize.height
        let visibleHeight = self.messagesCollectionView.bounds.size.height - self.messageInputBar.bounds.height
        if contentHeight > visibleHeight {
            self.messagesCollectionView.contentOffset = CGPoint(x: 0, y: contentHeight - visibleHeight)
        }
    }
    
    @discardableResult func handleTapAvatar(in cell: MessageCollectionViewCell, at indexPath: IndexPath) -> Bool {
        if let id = UInt64(messages[indexPath.section].sender.id), let user = members[id] {
            delegate?.conversationControllerShowsProfile(buddy: user)
            return true
        }
        return false
    }
    
    @discardableResult func handleTapMessage(in cell: MessageCollectionViewCell, at indexPath: IndexPath) -> Bool {
        let message = messages[indexPath.section]
        if let content = message.content as? ImageMessageContent,
            let cell = cell as? ImageMessageCell, message.type == .image {
            let browserDelegate =
                PhotoBrowserImp(thumbnaiImageViews: [cell.imageView], highImageViewURLs: [URL(string: content.url)!])
            photoBrowserDelegate = browserDelegate
            let browser = CustomPhotoBrowser(delegate: browserDelegate,
                                             photoLoader: SDWebImagePhotoLoader(),
                                             originPageIndex: 0)
            browser.animationType = .scale
            browser.plugins.append(CustomNumberPageControlPlugin())
            browser.show()
            return true
        }
        if let content = message.content as? OptionCardContent {
            let preview = OptionCardPreviewController(content: content, user: self.user)
            preview.showProfile = { [weak self] (buddyID, setTop, finishBlock) in
                self?.delegate?.conversationControllerShowsProfile(buddyID: buddyID, setTop: setTop)
            }
            let popup = PopupController(rootViewController: preview)
            popup.present(in: self)
            return true
        }
        if let content = message.content as? ContentCardContent {
            delegate?.conversationControllerShowsShareWebView(url: content.url, cardId: content.identifier)
            return true
        }
        if let content = message.content as? ArticleMessageContent {
            delegate?.conversationControllerShowsShareWebView(url: content.articleURL, cardId: content.identifier)
            return true
        }
        if let content = message.content as? StoryMessageContent {
            web.request(
                .getStory(storyID: content.identifier),
                responseType: Response<StoryGetResponse>.self
            ) { [weak self] (result) in
                guard let `self` = self else { return }
                switch result {
                case .failure(let error):
                    logger.error(error)
                case .success(let response):
                    self.contentInsetBottom = self.messagesCollectionView.contentInset.bottom
                    self.contentOffset = self.messagesCollectionView.contentOffset
                    self.delegate?.conversationControllerShowsStory(
                        StoryCellViewModel(model: response.story),
                        user: self.user,
                        messageId: message.messageId
                    )
                    if let cell = cell as? StoryMessageCell {
                        cell.thumbnailImageView.hero.isEnabled = true
                        cell.thumbnailImageView.hero.id = "\(response.story.userId)" + message.messageId
                        cell.thumbnailImageView.hero.modifiers = [.arc]
                    }
                }
            }
            return true
        }
        return false
    }
    
    func didBlock(userID: UInt64) {}
    
    func didUnblock(userID: UInt64) {}
    
    // MARK: - Private
    
    private func resplaceWithSweetCollectionView() {
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
    }
    
    private func setupCollectionView() {
        messagesCollectionView.contentInset = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 0)
        messagesCollectionView.register(StoryMessageCell.self)
        messagesCollectionView.register(OptionCardMessageCell.self)
        messagesCollectionView.register(ContentCardMessageCell.self)
        messagesCollectionView.register(SweetTextMessageCell.self)
        messagesCollectionView.register(ImageMessageCell.self)
        messagesCollectionView.register(ArticleMessageCell.self)
        messagesCollectionView.backgroundColor = .clear
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
    }
    
    private func setupInputBar() {
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        messageInputBar.isTranslucent = false
        messageInputBar.separatorLine.isHidden = true
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "SendButton"), for: .normal)
        messageInputBar.sendButton.setImage(#imageLiteral(resourceName: "SendButtonDisabled"), for: .disabled)
        messageInputBar.sendButton.setTitle(nil, for: .normal)
        messageInputBar.padding.right = 2
        messageInputBar.backgroundView.backgroundColor = .white
        messageInputBar.inputTextView.backgroundColor = .clear
        messageInputBar.inputTextView.placeholder = "输入你想说的话"
        messageInputBar.inputTextView.layer.borderWidth = 0
    }
    
    private func makeBubbleMask(isIncomming: Bool) -> UIImageView {
        if isIncomming {
            return UIImageView(image: inComingBubbleMaskImage)
        }
        return UIImageView(image: outgoingBubbleMaskImage)
    }
}

extension ConversationViewController: MessagesLayoutDelegate { }

extension ConversationViewController: MessagesDataSource {
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func currentSender() -> Sender {
        return Sender(id: "\(user.userId)", displayName: user.nickname)
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    @discardableResult func addAccessoryIndicatorIfNeeds(_ accessoryView: UIView) -> UIActivityIndicatorView {
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
    
    @discardableResult func addAccessoryResendButtonIfNeeds(_ accessoryView: UIView) -> IndexPathButton {
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
    
    @objc func didPressResendButton(button: IndexPathButton) {
        guard let indexPath = button.indexPath else { return }
        var message = messages[indexPath.section]
        message.isFailed = false
        messages[indexPath.section] = message
        messagesCollectionView.reloadSections([indexPath.section])
        Messenger.shared.send(message)
    }
}

extension ConversationViewController: MessageCellDelegate {
    func didTapMessage(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        handleTapMessage(in: cell, at: indexPath)
    }
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        guard let indexPath = messagesCollectionView.indexPath(for: cell) else { return }
        handleTapAvatar(in: cell, at: indexPath)
    }
}

extension ConversationViewController: MessagesDisplayDelegate {
    func configureAvatarView(_ avatarView: AvatarView,
                             for message: MessageType,
                             at indexPath: IndexPath,
                             in messagesCollectionView: MessagesCollectionView) {
        avatarView.placeholderTextColor = .gray
        avatarView.backgroundColor = .clear
        if let id = UInt64(message.sender.id) {
            if let user = members[id] {
                avatarView.sd_setImage(
                    with: URL(string: user.avatar),
                    placeholderImage: #imageLiteral(resourceName: "Logo"),
                    options: SDWebImageOptions(rawValue: 0),
                    completed: nil
                )
            } else {
                loadMember(id) { [weak avatarView] (user) in
                    guard let user = user else { return }
                    avatarView?.sd_setImage(
                        with: URL(string: user.avatar),
                        placeholderImage: #imageLiteral(resourceName: "Logo"),
                        options: SDWebImageOptions(rawValue: 0),
                        completed: nil
                    )
                }
            }
        }
    }
    
    func messageStyle(for message: MessageType,
                      at indexPath: IndexPath,
                      in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        return .custom({ [weak self] (container) in
            guard let `self` = self else { return }
            let isIncomming = message.sender.id != "\(self.user.userId)"
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
    
    func backgroundColor(for message: MessageType,
                         at indexPath: IndexPath,
                         in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return .white
    }
    
    func textColor(for message: MessageType,
                   at indexPath: IndexPath,
                   in messagesCollectionView: MessagesCollectionView) -> UIColor {
        if message.sender.id == "\(user.userId)" {
            return .white
        }
        return .black
    }
    
    func avatarSize(for message: MessageType,
                    at indexPath: IndexPath,
                    in messagesCollectionView: MessagesCollectionView) -> CGSize {
        return CGSize(width: 32, height: 32)
    }
    
    func configureAccessoryView(_ accessoryView: UIView,
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
}

extension ConversationViewController: STPopupPreviewRecognizerDelegate {
    func previewViewController(for popupPreviewRecognizer: STPopupPreviewRecognizer) -> UIViewController? {
        guard
            let cell = popupPreviewRecognizer.view as? UICollectionViewCell,
            let indexPath = messagesCollectionView.indexPath(for: cell)
            else {
                return nil
        }
        let message = messages[indexPath.section]
        if let content = message.content as? OptionCardContent {
            return OptionCardPreviewController(content: content, user: user)
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
