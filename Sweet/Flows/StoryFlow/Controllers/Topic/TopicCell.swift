//
//  TopicCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicCell: UITableViewCell {
    var topic = "" {
        didSet {
            updateTopic()
        }
    }
    private let topicLabel = UILabel()
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        let image = #imageLiteral(resourceName: "TopicCell")
            .resizableImage(
                withCapInsets: UIEdgeInsets(top: 22, left: 5, bottom: 23, right: 6),
                resizingMode: .stretch
        )
        let imageView = UIImageView(image: image)
        contentView.addSubview(imageView)
        imageView.fill(in: contentView, left: 10, right: 10, top: 1, bottom: 1)
        contentView.addSubview(topicLabel)
        topicLabel.fill(in: contentView, left: 25, right: 25, top: 0, bottom: 0)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        updateTopic()
    }
    
    private func updateTopic() {
        let fontSize: CGFloat = 16
        if isSelected {
            topicLabel.attributedText = NSMutableAttributedString(
                topic: topic,
                fontSize: fontSize,
                textColor: UIColor(hex: 0xF8E71C)
            )
        } else {
            topicLabel.attributedText = NSMutableAttributedString(topic: topic, fontSize: fontSize)
        }
    }
}
