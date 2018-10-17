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
    private var conversation: IMConversation?
    private var userAttributedNames = [UInt64: NSAttributedString]()
    private var topUsersView: TopUsersView?
    
    init(user: User, group: Group, conversation: IMConversation? = nil) {
        self.group = group
        self.conversation = conversation
        super.init(user: user)
        Messenger.shared.addDelegate(self)
        Messenger.shared.loadMessages(from: group, conversation: conversation)
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
        loadTopUsers()
    }
    
    private func setMessagesCollectionViewHeader() {
        topUsersView = TopUsersView(frame: CGRect(x: 0, y: UIScreen.navBarHeight(), width: UIScreen.mainWidth(), height: 64))
        messagesCollectionView.contentInset.top += 64
        topUsersView?.showProfile = { [weak self] buddyID in
            self?.delegate?.conversationControllerShowsProfile(buddyID: buddyID)
        }
        topUsersView?.backgroundColor = UIColor(hex: 0xF2F2F2)
        topUsersView?.layer.shadowRadius = 2
        topUsersView?.layer.shadowColor = UIColor(hex: 0xE0E0E0).cgColor
        topUsersView?.layer.shadowOpacity = 0.4
        topUsersView?.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.addSubview(topUsersView!)
    }
    
    private func loadTopUsers() {
        web.request(
            .groupUserRanking(groupId: group.id),
            responseType: Response<UserRankingListResponse>.self) { (result) in
                switch result {
                case .success(let response):
                    if response.list.count > 0 {
                        self.setMessagesCollectionViewHeader()
                        self.topUsersView?.update(userRankingList: response.list)
                    }
                case .failure(let error):
                    logger.debug(error)
                }
        }
    }

    @objc private func didPressRightBarButton() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        controller.view.tintColor = .black
        controller.addAction(
            UIAlertAction(title: group.isMuted ? "打开消息通知" : "消息免打扰", style: .default, handler: { [weak self] _ in
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
    
    override func messageTopLabelHeight(for message: MessageType,
                               at indexPath: IndexPath,
                               in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 17
    }
    
    override func messageTopLabelAttributedText(for message: MessageType,
                                       at indexPath: IndexPath) -> NSAttributedString? {
        guard let id = UInt64(messages[indexPath.section].sender.id) else { return nil }
        if let text = userAttributedNames[id] {
            return text
        }
        
        if let member = members[id] {
            let string: String
            if user.userId == member.userId {
                string = "我"
            } else {
                if let university = member.universityName, university.isEmpty == false {
                    string = "\(member.nickname) · \(university)"
                } else {
                    string = member.nickname
                }
            }
            let text = NSAttributedString(string: string,
                                          attributes: [.font : UIFont.systemFont(ofSize: 12),
                                                       .foregroundColor: UIColor(hex: 0x4a4a4a)])
            userAttributedNames[id] = text
            return text
        }
        
        return nil
    }
}
extension GroupConversationController {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        let contentOffetY = scrollView.contentOffset.y
//        topUsersView?.frame.origin.y = -contentOffetY - messagesCollectionView.contentInset.top
    }
}

extension GroupConversationController: MessageInputBarDelegate {
    func messageInputBar(_ inputBar: MessageInputBar, didPressSendButtonWith text: String) {
        let message = Messenger.shared.sendText(text, from: user.userId, to: group.id, isGroup: true)
        messages.append(message)
        messagesCollectionView.insertSections([messages.isEmpty ? 0 : messages.count - 1])
        inputBar.inputTextView.text = ""
        messagesCollectionView.scrollToBottom(animated: true)
    }
}

extension GroupConversationController: MessengerDelegate {
    func messengerDidBeginFetchMessages(group: Group) {
        guard group.id == self.group.id else { return }
        showLoadingIndicator(true)
    }
    
    func messengerDidFetchMessages(group: Group) {
        guard group.id == self.group.id else { return }
        showLoadingIndicator(false)
    }
    
    func messengerDidLoadMessages(_ messages: [InstantMessage], group: Group) {
        guard group.id == self.group.id else { return }
        self.messages = messages
        reloadDataAndGoToBottom()
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
            messagesCollectionView.insertSections([messages.isEmpty ? 0 : messages.count - 1])
            messagesCollectionView.scrollToBottom(animated: true)
        }
    }
    
    func messengerDidReceiveMessage(_ message: InstantMessage) {
        guard message.to == group.id else { return }
        self.messages.append(message)
        messagesCollectionView.insertSections([messages.isEmpty ? 0 : messages.count - 1])
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
