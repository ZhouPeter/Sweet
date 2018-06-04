//
//  ConversationCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/30.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit
import Kingfisher
import SwipeCellKit

final class ConversationCell: SwipeTableViewCell, CellReusable {
    private let avatarImageView: UIImageView = {
        let view = UIImageView()
        view.layer.cornerRadius = 25
        view.clipsToBounds = true
        view.contentMode = .scaleAspectFill
        view.image = #imageLiteral(resourceName: "Logo")
        return view
    } ()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 16)
        label.text = "经管吴亦凡"
        return label
    } ()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor(hex: 0xB2B2B2)
        label.text = "上午10:18"
        return label
    } ()
    
    private let contentLabel: UILabel = {
        let label = UILabel ()
        label.textColor = UIColor(hex: 0xB2B2B2)
        label.font = UIFont.systemFont(ofSize: 13)
        label.text = "火影忍者更新了  最新有3集快去看, 火影忍者更新了最新有3集快去看"
        return label
    } ()
    
    private let badgeView = BadgeView(cornerRadius: 10)
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    
    func updateWith(_ conversation: Conversation) {
        avatarImageView.kf.setImage(with: URL(string: conversation.user.avatar))
        nameLabel.text = conversation.user.nickname
        contentLabel.text = conversation.lastMessage?.displayText
        if conversation.unreadCount > 0 {
            badgeView.text = conversation.unreadCount > 99 ? "99+" : "\(conversation.unreadCount)"
            badgeView.isHidden = false1234567890
        } else {
            badgeView.isHidden = true
        }
    }
    
    private func setup() {
        contentView.addSubview(avatarImageView)
        avatarImageView.constrain(width: 50, height: 50)
        avatarImageView.align(.left, inset: 10)
        avatarImageView.centerY(to: contentView)
        contentView.addSubview(timeLabel)
        contentView.addSubview(nameLabel)
        timeLabel.align(.right, inset: 10)
        timeLabel.align(.top, to: nameLabel)
        nameLabel.pin(.right, to: avatarImageView, spacing: 10)
        nameLabel.align(.top, to: avatarImageView, inset: 2)
        nameLabel.pin(.left, to: timeLabel, spacing: 10)
        contentView.addSubview(contentLabel)
        contentLabel.pin(.right, to: avatarImageView, spacing: 10)
        contentLabel.align(.bottom, to: avatarImageView)
        contentLabel.align(.right, inset: 70)
        contentView.addSubview(badgeView)
        badgeView.align(.right, to: timeLabel)
        badgeView.centerY(to: contentLabel)
    }
}
