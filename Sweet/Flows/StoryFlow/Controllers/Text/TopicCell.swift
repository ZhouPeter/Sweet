//
//  TopicCell.swift
//  Sweet
//
//  Created by Mario Z. on 2018/5/14.
//  Copyright © 2018年 Miaozan. All rights reserved.
//

import UIKit

final class TopicCell: UITableViewCell {
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
