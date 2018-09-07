//
//  ConversationControllerDelegate.swift
//  Sweet
//
//  Created by Mario Z. on 2018/6/26.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import Foundation

protocol ConversationControllerDelegate: class {
    func conversationControllerShowsProfile(buddy: User)
    func conversationControllerShowsProfile(buddyID: UInt64, setTop: SetTop?)
    func conversationControllerShowsShareWebView(url: String, cardId: String)
    func conversationControllerReports(buddy: User)
    func conversationController(_ controller: ConversationController, blocksBuddy buddy: User)
    func conversationController(_ controller: ConversationController, unblocksBuddy buddy: User)
    func conversationControllerShowsStory(_ viewModel: StoryCellViewModel, user: User, messageId: String)
    func conversationDidFinish()
}

extension ConversationControllerDelegate {
    func conversationDidFinish() {}
}
